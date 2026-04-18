#!/bin/bash
set -ueo pipefail

REFS_PATH=./references/sequences
ASSEMBLY_FILTERED=./output/assemblies/assembly_no-ma-ab.fasta

# add header IDs to refs for downstream identification
sed 's/^>/>Ab_/' $REFS_PATH/a-baylyi_cds.fna > $REFS_PATH/a-baylyi_cds_prefixed.fa
sed 's/^>/>Ma_/' $REFS_PATH/m-aeruginosa_cds.fna > $REFS_PATH/m-aeruginosa_cds_prefixed.fa
sed 's/^>/>Asm_/' $ASSEMBLY_FILTERED > $REFS_PATH/asm_no-ma-ab_prefixed.fa

# cat refs together into master ref of Ma cds, Ab cds, and de novo transcriptome contigs
# to prevent multi-mapping of conserved reads 
cat $REFS_PATH/a-baylyi_cds_prefixed.fa $REFS_PATH/m-aeruginosa_cds_prefixed.fa $REFS_PATH/asm_no-ma-ab_prefixed.fa \
 > $REFS_PATH/ma-ab-asm_prefixed_ref.fa

# generate index file for Salmon
# -t: specify ref data to be indexed
# -i: specify output index name
# -k = 31: minimum length to count as a match
mkdir -p ./output/counts/raw
RAW_COUNTS=./output/counts/raw
salmon index -t $REFS_PATH/ma-ab-asm_prefixed_ref.fa -i $RAW_COUNTS/ma-ab-asm_index -k 31

# quantify gene counts for each clean, rrna filtered data file
# -l A: auto-determine library type
# -r: merged/paired-end data
# -p: request threads based on slurm cpus per task
FILTERED_DIR=./data/filtered
for i in $(cat ./data/clean_metadata.tsv | cut -f5 | tail -n +2); 
do CLEAN_FILTERED=${FILTERED_DIR}/${i/_1.fq.gz/_clean_filtered.fq.gz};

        BASE_NAME=$(basename "$CLEAN_FILTERED" _clean_filtered.fq.gz)
        OUT_DIR=$RAW_COUNTS/${BASE_NAME}_transcripts

        salmon quant -i $RAW_COUNTS/ma-ab-asm_index -l A -r $CLEAN_FILTERED -p $SLURM_CPUS_PER_TASK --validateMappings -o $OUT_DIR

done

# generate summary tsv quantifying total counts for ma, ab, and assembly (asm) at each timepoint/condition 
OUTPUT_TSV=./output/counts/salmon_counts_metadata.tsv
TEMP_TSV="temp_data.tsv" # Temporary file to hold the rows before sorting

# 1. Clear the temp file just in case it already exists from a previous run
> "$TEMP_TSV"

# 2. Loop through every quant.sf file inside the transcript directories
for quant_file in $RAW_COUNTS/*_transcripts/quant.sf; do
    
    # Safety check to ensure the file exists
    if [[ -f "$quant_file" ]]; then
        
        # Extract just the base sample name (e.g., V350357263_L03_1)
        dir_name=$(dirname "$quant_file")
        sample_name=$(basename "$dir_name" | sed 's/_transcripts//')

        # 3. Fetch metadata from your TSV
        target_fwd="${sample_name}_1.fq.gz"
        meta_info=$(awk -v target="$target_fwd" -F'\t' '$5 == target {print $2 "\t" $3 "\t" $4}' "./data/clean_metadata.tsv")
        
        # Fill with NA if not found
        if [[ -z "$meta_info" ]]; then
            meta_info="NA\tNA\tNA"
        fi

        # 4. Use awk to sum the reads and append everything to the TEMP file
        awk -v sample="$sample_name" -v meta="$meta_info" '
            BEGIN { ma=0; ab=0; asm=0 }
            $1 ~ /^Ma_/ { ma += $5 }
            $1 ~ /^Ab_/ { ab += $5 }
            $1 ~ /^Asm_/ { asm += $5 }
            END { printf "%s\t%s\t%.0f\t%.0f\t%.0f\n", sample, meta, ma, ab, asm }
        ' "$quant_file" >> "$TEMP_TSV"
    fi
done

# 5. Create the final TSV with the header row
printf "Sample\tTimepoint\tTreatment\tReplicate\tMa_counts\tAb_counts\tAsm_counts\n" > "$OUTPUT_TSV"

# 6. Sort the temp data logically (-V) and append it to the final TSV
sort -V "$TEMP_TSV" >> "$OUTPUT_TSV"

# 7. Clean up by removing the temporary file
rm "$TEMP_TSV"
