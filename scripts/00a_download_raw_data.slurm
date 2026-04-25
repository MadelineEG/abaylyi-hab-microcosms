#!/bin/bash
#SBATCH --job-name=download-raw
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH -o download-raw_%j.out
#SBATCH -e download-raw_%j.err

# download raw fastqs from SRA

# (write code once upload to SRA)

# summarize total read numbers
OUTTSV=./data/raw-reads_summary.tsv
METADATA=./data/clean_metadata.tsv
echo -e "sample_number\ttimepoint\ttreatment\treplicate\tfwd\trev\tfwd_reads\trev_reads\ttotal_reads" > "$OUTTSV"

tail -n +2 "$METADATA" | while IFS=$'\t' read -r sample_number timepoint treatment replicate fwd rev; do 
FWD=./data/raw/${fwd}; 
REV=${FWD/_1.fq.gz/_2.fq.gz};
FWD_READS=$(zcat $FWD | wc -l | awk '{print $1/4}');
REV_READS=$(zcat $REV | wc -l | awk '{print $1/4}');
TOTAL=$(($FWD_READS + $REV_READS))

echo -e "${sample_number}\t${timepoint}\t${treatment}\t${replicate}\t${fwd}\t${rev}\t${FWD_READS}\t${REV_READS}\t${TOTAL}" >> "$OUTTSV"

done
