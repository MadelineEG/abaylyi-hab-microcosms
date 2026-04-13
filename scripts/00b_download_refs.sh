#!/bin/bash
set -ueo pipefail

mkdir -p ./references/sequences

OUT_DIR=./references/sequences

cd $OUT_DIR

# Activate env to use ncbi Datasets
module load miniforge3
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate de-env

# Download cds and gff for A. baylyi ADP1 GCF_000046845.1
datasets download genome accession GCF_000046845.1 --include cds,gff3 \
 --filename a-baylyi_refs.zip

# Rename resulting files
unzip -q -o a-baylyi_refs.zip
mv ncbi_dataset/data/GCF_000046845.1/cds_from_genomic.fna a-baylyi_cds.fna
mv ncbi_dataset/data/GCF_000046845.1/genomic.gff a-baylyi.gff

rm -r ncbi_dataset
rm a-baylyi_refs.zip

# Download cds and gff for M. aeruginosa LE3 (UTEX 3037) GCF_032701645.1
datasets download genome accession GCF_032701645.1 --include cds,gff3 \
 --filename m-aeruginosa_refs.zip

# Rename resulting files
unzip -q -o m-aeruginosa_refs.zip
mv ncbi_dataset/data/GCF_032701645.1/cds_from_genomic.fna m-aeruginosa_cds.fna
mv ncbi_dataset/data/GCF_032701645.1/genomic.gff m-aeruginosa.gff
 
rm -r ncbi_dataset
rm m-aeruginosa_refs.zip

# Deactivate env and return to original directory
conda deactivate
cd ../..

