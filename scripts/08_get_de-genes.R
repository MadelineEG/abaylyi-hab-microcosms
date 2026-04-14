library(DESeq2)

# read txi outputs of previous tximport step
txi_Ab <- readRDS("./output/counts/formatted/txi_Ab.rds")
txi_Ma <- readRDS("./output/counts/formatted/txi_Ma.rds")

# read existing metadata table as meta
meta <- read.table("./data/clean_metadata.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# create combined condition-timept col in meta for easy reference w/ DESeq (contains all replicates for given grp)
meta$group <- factor(paste0(meta$timepoint, "_", meta$treatment))

# obtain fwd column of metadata table, get name matching txi counts table
# set the above as rownames of meta -- bc metadata row names must exactly match txi counts colnames
rownames(meta) <- gsub("_1.fq.gz", "_transcripts", meta$fwd)

# make meta's row order match order of Ab (and Ma) txi cols
meta <- meta[colnames(txi_Ab$counts), ]

# check if meta row order matches txi col order -- True if so
all(rownames(meta) == colnames(txi_Ab$counts))
all(rownames(meta) == colnames(txi_Ma$counts))

# create DESeq objects -- using new "group" col in metadata as the comparison
dds_Ab <- DESeqDataSetFromTximport(txi_Ab, colData = meta, design = ~ group)
dds_Ma <- DESeqDataSetFromTximport(txi_Ma, colData = meta, design = ~ group)

# run DESeq
dds_Ab <- DESeq(dds_Ab)
dds_Ma <- DESeq(dds_Ma)

# set up comparisons from above
# Ab: T1, T3, T4 (Day 1, 5, 7) Matoaka vs Ctrl
T1_MvC_Ab <- results(dds_Ab, contrast = c("group", "T1_Matoaka", "T1_Control"))
T3_MvC_Ab <- results(dds_Ab, contrast = c("group", "T3_Matoaka", "T3_Control"))
T4_MvC_Ab <- results(dds_Ab, contrast = c("group", "T4_Matoaka", "T4_Control"))

# Ma: T1, T3, T4 (Day 1, 5, 7) Matoaka vs Ctrl
T1_MvC_Ma <- results(dds_Ma, contrast = c("group", "T1_Matoaka", "T1_Control"))
T3_MvC_Ma <- results(dds_Ma, contrast = c("group", "T3_Matoaka", "T3_Control"))
T4_MvC_Ma <- results(dds_Ma, contrast = c("group", "T4_Matoaka", "T4_Control"))

# get csvs of DESeq output 
# Ab Matoaka vs Ctrl comparisons
write.csv(as.data.frame(T1_MvC_Ab), file = "./output/de-genes/T1_Matoaka_vs_Control_Ab.csv")
write.csv(as.data.frame(T3_MvC_Ab), file = "./output/de-genes/T3_Matoaka_vs_Control_Ab.csv")
write.csv(as.data.frame(T4_MvC_Ab), file = "./output/de-genes/T4_Matoaka_vs_Control_Ab.csv")

# Ma Matoaka vs Ctrl comparisons
write.csv(as.data.frame(T1_MvC_Ma), file = "./output/de-genes/T1_Matoaka_vs_Control_Ma.csv")
write.csv(as.data.frame(T3_MvC_Ma), file = "./output/de-genes/T3_Matoaka_vs_Control_Ma.csv")
write.csv(as.data.frame(T4_MvC_Ma), file = "./output/de-genes/T4_Matoaka_vs_Control_Ma.csv")

# get only significant outputs
T1_MvC_Ab_Sig <- subset(T1_MvC_Ab, padj < 0.05)
T3_MvC_Ab_Sig <- subset(T3_MvC_Ab, padj < 0.05)
T4_MvC_Ab_Sig <- subset(T4_MvC_Ab, padj < 0.05)

T1_MvC_Ma_Sig <- subset(T1_MvC_Ma, padj < 0.05)
T3_MvC_Ma_Sig <- subset(T3_MvC_Ma, padj < 0.05)
T4_MvC_Ma_Sig <- subset(T4_MvC_Ma, padj < 0.05)

# get significant CSVs
# Ab Matoaka vs Ctrl comparisons
write.csv(as.data.frame(T1_MvC_Ab_Sig), file = "./output/de-genes/T1_Matoaka_vs_Control_Ab_Sig.csv")
write.csv(as.data.frame(T3_MvC_Ab_Sig), file = "./output/de-genes/T3_Matoaka_vs_Control_Ab_Sig.csv")
write.csv(as.data.frame(T4_MvC_Ab_Sig), file = "./output/de-genes/T4_Matoaka_vs_Control_Ab_Sig.csv")

# Ma Matoaka vs Ctrl comparisons
write.csv(as.data.frame(T1_MvC_Ma_Sig), file = "./output/de-genes/T1_Matoaka_vs_Control_Ma_Sig.csv")
write.csv(as.data.frame(T3_MvC_Ma_Sig), file = "./output/de-genes/T3_Matoaka_vs_Control_Ma_Sig.csv")
write.csv(as.data.frame(T4_MvC_Ma_Sig), file = "./output/de-genes/T4_Matoaka_vs_Control_Ma_Sig.csv")

