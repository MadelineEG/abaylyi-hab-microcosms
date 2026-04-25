#!/bin/bash
#SBATCH --job-name=DOWNLOAD_DBS
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00
#SBATCH --mem=4G
#SBATCH -o DOWNLOAD_DBS_%j.out
#SBATCH -e DOWNLOAD_DBS_%j.err

set -ueo pipefail

# Establish base directory

BASE_DIR="${SLURM_SUBMIT_DIR}/references/databases"

# Download Kraken core_nt database
mkdir -p ${BASE_DIR}/kraken_core_nt
cd ${BASE_DIR}/kraken_core_nt

wget https://genome-idx.s3.amazonaws.com/kraken/k2_core_nt_20251015.tar.gz
tar -xvzf k2_core_nt_20251015.tar.gz
rm k2_core_nt_20251015.tar.gz

# Download SortMeRNA databases 
mkdir -p ${BASE_DIR}/sortmerna-dbs
cd ${BASE_DIR}/sortmerna-dbs

wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz
tar -xvzf database.tar.gz
rm database.tar.gz

cd ${BASE_DIR}
