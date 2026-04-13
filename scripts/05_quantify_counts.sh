#!/bin/bash
set -ueo pipefail

REFS_PATH=./references/sequences
ASSEMBLY_FILTERED=./output/assemblies/assembly_no-ma-ab.fasta

# add header IDs to refs for downstream identification
# prefixed outputs all into ma-ab_refs folder (need to fix file org)
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

