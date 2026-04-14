library(tximport)

# read tx2gene (TXNAME - LOCUS-TAG) keys linking salmon tx output to locus tag
tx2gene_Ab <- read.table("./references/id-conversion/Ab_tx2gene.tsv", header = TRUE, sep = "\t")
tx2gene_Ma <- read.table("./references/id-conversion/Ma_tx2gene.tsv", header = TRUE, sep = "\t")

# obtain salmon output folders
all_dirs <- list.dirs("./output/counts/raw", recursive = FALSE)
salmon_dirs <- grep("_transcripts$", all_dirs, value = TRUE)

# obtain file paths for quant.sf within salmon output folders
count_files <- file.path(salmon_dirs, "quant.sf")

# name files to correspond w/ folder names
names(count_files) <- basename(salmon_dirs)

# create txi object -- formatted counts (w/ locus tags as IDs) for input into DESeq
# should have abudance, counts, length, and countsFromAbundance
txi_Ab <- tximport(count_files, type = "salmon", tx2gene = tx2gene_Ab)
txi_Ma <- tximport(count_files, type = "salmon", tx2gene = tx2gene_Ma)

# save the txi objects for access by DESeq script
saveRDS(txi_Ab, file = "./output/counts/formatted/txi_Ab.rds")
saveRDS(txi_Ma, file = "./output/counts/formatted/txi_Ma.rds")

# visually check if txi generated - see counts result
head(txi_Ab$counts)
head(txi_Ma$counts)

