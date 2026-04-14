#!/bin/bash
set -ueo pipefail

mkdir -p ./data/clean

for i in $(cat ./data/clean_metadata.tsv | cut -f5 | tail -n +2); 
do FWD=./data/raw/${i}; 
REV=${FWD/_1.fq.gz/_2.fq.gz};
OUT=./data/clean/${i/_1.fq.gz/_clean.fq.gz};

# running fastp
# merge fwd and rev
# discard reads less than 50 bp
# remove low-complexity
# remove poly-X tails
# retain reads that can't merge
fastp -i $FWD -I $REV -m -l 50 -x -y --include_unmerged --merged_out $OUT \
      --json /dev/null --html /dev/null
done
