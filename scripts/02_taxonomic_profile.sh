#!/bin/bash
set -ueo pipefail

mkdir -p ./output/taxonomy

CLEAN_DIR=./data/clean
KRAKEN_DB=./references/databases/kraken_core_nt
OUT_DIR=./output/taxonomy

for i in $(cat ./data/clean_metadata.tsv | cut -f5 | tail -n +2); 
do CLEAN=${CLEAN_DIR}/${i/_1.fq.gz/_clean.fq.gz};

kraken2 --db $KRAKEN_DB \
         --threads $SLURM_CPUS_PER_TASK \
         --report $OUT_DIR/${i/_1.fq.gz/_kraken_report.txt} \
         --output $OUT_DIR/${i/_1.fq.gz/_kraken_output.txt} \
         --gzip-compressed \
         $CLEAN
done
