#!/bin/bash
set -ueo pipefail

# (Created with Gemini for regular expressions)

# Define your input FASTA files
AB_FASTA=./references/sequences/a-baylyi_cds_prefixed.fa
MA_FASTA=./references/sequences/m-aeruginosa_cds_prefixed.fa

# Output file paths
OUT_DIR=./references/id-conversion

# 1. Create the A. baylyi mapping file: prefixed transcript name to locus tag
# Write the header row
printf "TXNAME\tLOCUS-TAG\n" > $OUT_DIR/Ab_tx2gene.tsv

# Grep out only the header lines (starting with >), then use sed to format them
grep "^>" "$AB_FASTA" | \
sed -n 's/^>\([^ ]*\).*\[locus_tag=\([^]]*\)\].*/\1\t\2/p' >> $OUT_DIR/Ab_tx2gene.tsv

# 2. Create the M. aeruginosa mapping file
# Write the header row
printf "TXNAME\tLOCUS-TAG\n" > $OUT_DIR/Ma_tx2gene.tsv

# Grep and sed the Ma file
grep "^>" "$MA_FASTA" | \
sed -n 's/^>\([^ ]*\).*\[locus_tag=\([^]]*\)\].*/\1\t\2/p' >> $OUT_DIR/Ma_tx2gene.tsv

