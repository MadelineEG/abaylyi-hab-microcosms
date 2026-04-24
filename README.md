# abaylyi-hab-microcosms
**Madeline Eibner-Gebhardt, 2026**  
*William & Mary iGEM 2025*

Pipeline to obtain differential gene expression (DE) data and taxonomic profiles for metatranscriptomic data from nonsterile lakewater microcosms and control cultures inoculated with chassis bacterium *Acinetobacter baylyi* ADP1-ISx and bloom-causing cyanobacterium *Microcystis aeruginosa* LE3.

<img src="microcosms.png" width="400">

## Dependencies

### Software Tools
All relevant software tools and their dependencies are included in the Conda environments **de-env** and **salmon-env**. Below are the key tools and version numbers:
* **ncbi-datasets-cli:** 18.23.0
* **fastp:** 1.3.2
* **kraken2:** 2.17.1
* **sortmerna:** 4.3.7
* **spades:** 4.2.0
* **minimap2:** 2.30
* **samtools:** 1.23.1
* **salmon:** 1.11.4
* **R:** 4.5.3
* **tximport:** 1.38.2
* **deseq2:** 1.50.2

### Reference Sequences and Databases
* ***A. baylyi*** ADP1 GCF_000046845.1
* ***M. aeruginosa*** LE3 GCF_032701645.1
* **Kraken core-nt db:** k2_core_nt_20251015
* **SortMeRNA default db:** smr_v4.3_default_db

## Directory Structure
```bash
.
├── data
│   ├── clean
│   ├── clean_metadata.tsv
│   ├── filtered
│   ├── raw
│   └── raw-reads_summary.tsv
├── de-env.yml
├── output
│   ├── assemblies
│   ├── counts
│   │   ├── formatted
│   │   └── raw
│   ├── de-genes
│   └── taxonomy
├── pipeline.slurm
├── README.md
├── references
│   ├── databases
│   ├── id-conversion
│   └── sequences
├── salmon-env.yml
└── scripts
    ├── 00a_download_raw_data.slurm
    ├── 00b_download_refs.sh
    ├── 00c_download_databases.slurm
    ├── 00__create_envs.sh
    ├── 00__setup.sh
    ├── 01_clean_raw_data.sh
    ├── 02_taxonomic_profile.sh
    ├── 03_deplete_rrna.sh
    ├── 04_assemble_ref.sh
    ├── 05_quantify_counts.sh
    ├── 06_create_tx2gene_ref.sh
    ├── 07_format_input.R
    ├── 08_get_de-genes.R
    └── 09_get_proteins.R
```

## Setup
Before running the pipeline, clone this repository and run the below setup steps in order from the project directory:
1. Ensure basic directory structure
```bash
./scripts/00__setup.sh
```
2. Create conda environments using the provided .yml files
```bash
./scripts/00__create_envs.sh
```
3. Download raw data from SRA and generate reads summary
```bash
sbatch ./scripts/00a_download_raw_data.slurm
```
4. Download *A. baylyi* and *M. aeruginosa* reference sequences
```bash
./scripts/00b_download_refs.sh
``` 
5. Download reference databases for Kraken2 and SortMeRNA 
```bash
sbatch ./scripts/00c_download_databases.slurm
```

## Usage
After completing the setup steps above, run the below command from the project directory:
```bash
sbatch pipeline.slurm
```

## Overview
01) Clean raw data with **fastp**
02) Generate taxonomic profile with **Kraken2** vs. **kraken_core_nt** database
03) Deplete rRNA with **SortMeRNA** vs. **smr_v4.3_default_db** database
04) Assemble **SPAdes** ref transcriptome of reads *not* matching *A. baylyi* or *M. aeruginosa* (via alignment, filtering with **Samtools** and **Minimap2**)
05) Quantify counts via competitive **Salmon** alignment to above assembly and *A. baylyi*, *M. aeruginosa* refs
06) Create transcript name to locus tag (tx2gene) refs
07) Format counts with **Tximport** and tx2gene refs
08) Obtain DE gene lists with **DESeq2**
09) Associate DE locus tags with protein names

## Outputs
**Kraken taxonomic profile** reports containing read counts at all taxonomic levels can be found in the **./output/taxonomy** directory. Reports may be visualized and summarized with the **Pavian** web tool.

**DE gene lists** containing lists of significantly DE genes (padj<0.05) in csv format can be found in the **./output/de-genes** directory. Files with ending _Sig_Protein.csv contain the locus tag *and* the associated protein name from the gff reference file. Files are labeled accourding to the timepoint, comparison of interest, and species. A positive log fold change indicates gene upregulation in microcosms with relation to the controls. See sample output below:

<img src="sample-de.png" width="800">

## References

Chen S. fastp 1.0: An ultra-fast all-round tool for FASTQ data quality control and preprocessing. iMeta 4.5 2025 https://doi.org/10.1002/imt2.70078

Danecek P, Bonfield JK, Liddle J, Marshall J, Ohan V, Pollard MO, Whitwham A, Keane T, McCarthy SA, Davies RM, Li H. Twelve years of SAMtools and BCFtools. GigaScience 2021 https://doi.org/10.1093/gigascience/giab008.

Kopylova E, Noé L, Touzet H. SortMeRNA: Fast and accurate filtering of ribosomal RNAs in metatranscriptomic data. Bioinformatics 2012 https://doi.org/10.1093/bioinformatics/bts611.

Li H. Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics 2018 https://doi.org/10.1093/bioinformatics/bty191.

Love MI, Huber W, Anders S. Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biol 2014 https://doi.org/10.1186/s13059-014-0550-8

O’Leary NA, Cox E, Holmes JB, Anderson WR, Falk R, Hem V, Tsuchiya MTN, Schuler GD, Zhang X, Torcivia J, Ketter A, Breen L, Cothran J, Bajwa H, Tinne J, Meric PA, Hlavina W, Schneider VA. Exploring and retrieving sequence and metadata for species across the tree of life with NCBI Datasets. Sci Data 2024 https://doi.org/10.1038/s41597-024-03571-y. 

Patro R, Duggal G, Love MI, Irizarry RA, Kingsford C. Salmon provides fast and bias-aware quantification of transcript expression. Nat Methods 2017 https://doi.org/10.1038/nmeth.4197.

Prjibelski A, Antipov D, Meleshko D, Lapidus A, Korobeynikov A. Using SPAdes de novo assembler. Current Protocols in Bioinformatics 2020 https://doi.org/10.1002/cpbi.102.

R Core Team. R: A Language and Environment for Statistical Computing. R Foundation for Statistical Computing, Vienna, Austria. 2025 https://www.R-project.org.

Soneson C, Love MI, Robinson MD. Differential analyses for RNA-seq: transcript-level estimates improve gene-level inferences. F1000Research 2015 https://doi.org/10.12688/f1000research.7563.2.

Wood DE, Lu J, Langmead, B. Improved metagenomic analysis with Kraken 2. Genome Biol 2019 https://doi.org/10.1186/s13059-019-1891-0.
