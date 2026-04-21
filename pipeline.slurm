#!/bin/bash
#SBATCH --job-name=abaylyi-rnaseq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=3-00:00:00
#SBATCH --mem=250G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=mweibnergebhar@wm.edu
#SBATCH -o abaylyi-rnaseq_%j.out
#SBATCH -e abaylyi-rnaseq_%j.err

set -ueo pipefail

########## SET UP ENVIRONMENT ##########

module load miniforge3
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate de-env

########## PROCESSING AND REFERENCE PREP ##########

### QUALITY CONTROL ###

# step 1: run fastp
if [ ! -f "./data/clean/V350357263_L03_18_clean.fq.gz" ]; then
./scripts/01_clean_raw_data.sh
fi

### TAXONOMIC PROFILE ###

# step 2: assign taxonomy with kraken2
if [ ! -f "./output/taxonomy/V350357263_L03_18_kraken_report.txt" ]; then
./scripts/02_taxonomic_profile.sh
fi

### DEPLETE RRNA ###

# step 3: run sortmerna on clean data
if [ ! -f "./data/filtered/V350357263_L03_18_clean_filtered.fq.gz" ]; then
./scripts/03_deplete_rrna.sh
fi

### ASSEMBLE REF METATRANSCRIPTOME ###

# step 4: assemble all data with RNAspades, filter out M. aerugiosa, A. baylyi reads
if [ ! -f "./output/assemblies/assembly_no-ma-ab.fasta" ]; then
./scripts/04_assemble_ref.sh
fi

########## SWITCH ENVS TO HANDLE SALMON DEPENDENCIES ##########

conda deactivate
conda activate salmon-env

### QUANTIFY COUNTS ###

# step 5: generate counts via salmon alignment to prefixed, combined, non-redundant ref
if [ ! -f "./output/counts/raw/V350357263_L03_18_transcripts/quant.sf" ]; then
./scripts/05_quantify_counts.sh
fi

########## SWITCH BACK TO DIFFERENTIAL EXPRESSION ENV ##########

conda deactivate
conda activate de-env

### FORMAT DESEQ INPUT ###

# step 6: create tx2gene refs relating M. aeruginosa, A.baylyi transcript names to locus tags
if [ ! -f "./references/id-conversion/Ma_tx2gene.tsv" ]; then
./scripts/06_create_tx2gene_ref.sh
fi

# step 7: create txi objects with tximport for input into DESeq
Rscript ./scripts/07_format_input.R

### GET DE GENES ###

# step 8: get M. aeruginosa, A. baylyi differential expression across conditions of interest via DESeq2
Rscript ./scripts/08_get_de-genes.R

# step 9: get DE gene lists with associated proteins
cd output/de-genes
Rscript ../../scripts/09_get_proteins.R

cd ../..

# exit env
conda deactivate
