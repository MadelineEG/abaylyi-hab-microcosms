#!/bin/bash
set -ueo pipefail

# combine all clean, rrna filtered data
FILTERED_DIR=./data/filtered
cat ${FILTERED_DIR}/*_clean_filtered.fq.gz > ${FILTERED_DIR}/all_samples_merged-clean.fq.gz

# assemble the merged data
MERGED_INPUT=${FILTERED_DIR}/all_samples_merged-clean.fq.gz
ASSEMBLY_DIR=./output/assemblies

mkdir -p ./output/assemblies/spades_outputs

# use RNAspades for transcriptome assembly
# specify threads
# ram limit 250 
spades.py --rna -s $MERGED_INPUT \
          -o $ASSEMBLY_DIR/spades_outputs \
          -t $SLURM_CPUS_PER_TASK \
          -m 250

# extract assemblies from output folder
mv $ASSEMBLY_DIR/spades_outputs/transcripts.fasta $ASSEMBLY_DIR/all_samples_assembled.fasta
mv $ASSEMBLY_DIR/spades_outputs/spades.log $ASSEMBLY_DIR/all_samples_spades.log

# cat refs specifying data to be filtered out of assembly
AB_REF=./references/sequences/a-baylyi_genome.fa
MA_REF=./references/sequences/m-aeruginosa_genome.fa

cat $AB_REF $MA_REF > ./references/sequences/combined_ma-ab_genome.fa

# filter reads matching M. aeruginosa or A. baylyi out of assembly
COMBINED_REF=./references/sequences/combined_ma-ab_genome.fa
ASSEMBLY=$ASSEMBLY_DIR/all_samples_assembled.fasta
ASSEMBLY_FILTERED=$ASSEMBLY_DIR/assembly_no-ma-ab.fasta

# align transcriptome assembly to Ma and Ab references 
# specify threads/CPUs
# output in SAM format
# aligning a long assembly to a reference, expected divergence ~1% 
# $COMBINED_REF is target/ref, $ASSEMBLY is query to be filtered

# -f 4: extract only unmapped reads (not matching Ma and Ab)
# - before > to clarify from pipe 
minimap2 -t 4 -a -x asm10 $COMBINED_REF $ASSEMBLY | samtools fasta -f 4 - > $ASSEMBLY_FILTERED

