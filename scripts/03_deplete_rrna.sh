#!/bin/bash
set -ueo pipefail

mkdir -p ./data/filtered

CLEAN_DIR=./data/clean
RNA_DB=./references/databases/sortmerna-dbs/smr_v4.3_default_db.fasta
OUT_DIR=./data/filtered

for i in $(cat ./data/clean_metadata.tsv | cut -f5 | tail -n +2); 
do CLEAN=${CLEAN_DIR}/${i/_1.fq.gz/_clean.fq.gz};
WORK_DIR=${OUT_DIR}/${i/_1.fq.gz/_work};
SAMPLE_NAME=${i/_1.fq.gz/_clean_filtered};
DISCARD_NAME=${i/_1.fq.gz/_rrna};

sortmerna --ref $RNA_DB --reads $CLEAN \
        --workdir $WORK_DIR \
        --fastx --aligned $OUT_DIR/$DISCARD_NAME  --other $OUT_DIR/$SAMPLE_NAME \
        --threads 8
done
