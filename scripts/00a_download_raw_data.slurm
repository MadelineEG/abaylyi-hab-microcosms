#!/bin/bash
#SBATCH --job-name=download-raw
#SBATCH --nodes=1 # how many physical machines in the cluster
#SBATCH --ntasks=1 # how many separate 'tasks' (stick to 1)
#SBATCH --cpus-per-task=20 # how many cores (bora max is 20)
#SBATCH --time=02:00:00 # d-hh:mm:ss or just No. of minutes
#SBATCH --mem=8G # how much physical memory (all by default)
#SBATCH --mail-type=FAIL,BEGIN,END # when to email you
#SBATCH --mail-user=mweibnergebhar@wm.edu # who to email
#SBATCH -o download-raw_%j.out #STDOUT to file (%j is jobID)
#SBATCH -e download-raw_%j.err #STDERR to file (%j is jobID)

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
