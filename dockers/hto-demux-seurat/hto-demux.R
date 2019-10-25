library("optparse")

args = commandArgs(trailingOnly=TRUE)

path_umi_count_matrix_directory <- args[1]
path_output <- args[2]
quantile <- args[3]

# convert from string to double
quantile = as.double(quantile)

library(Seurat)

# load
my_data.htos = Read10X(path_umi_count_matrix_directory, gene.column=1)

rownames(my_data.htos)

# shorten the hashtag names
# HTO_301-ACCCACCAGTAAGAC --> HTO-301
# H1_DMSO-ACCCACCAGTAAGAC --> H1-DMSO
# drop the last element (i.e. unmapped)
library(stringr)
shortened_hashtag_names <- head(str_replace(rownames(my_data.htos), "-.*$", ""), -1)
shortened_hashtag_names <- str_replace(shortened_hashtag_names, "_", "-")

# get the number of hashtags
num_of_hashtags = length(shortened_hashtag_names)

my_data.htos <- my_data.htos[1:num_of_hashtags, ]
rownames(my_data.htos) <- shortened_hashtag_names

rownames(my_data.htos)

dim(my_data.htos)

# Include cells where at least this many features are detected.
my_data.hashtag <- CreateSeuratObject(counts = my_data.htos)

dim(my_data.hashtag)

# Include cells where at least this many features are detected.
my_data.hashtag[["HTO"]] <- CreateAssayObject(counts = my_data.htos)

dim(my_data.hashtag)

my_data.hashtag <- NormalizeData(my_data.hashtag, assay = "HTO", normalization.method = "CLR")

my_data.hashtag <- HTODemux(my_data.hashtag, assay = "HTO", positive.quantile = quantile)

# Global classification results
table(my_data.hashtag$HTO_classification.global)

# Group cells based on the max HTO signal
Idents(my_data.hashtag) <- "HTO_maxID"

# comparing only the first four hashtags against all of the hashtags
RidgePlot(my_data.hashtag, assay = "HTO", features = rownames(my_data.hashtag[["HTO"]])[1:4], ncol = 2)

FeatureScatter(my_data.hashtag, feature1 = shortened_hashtag_names[1], feature2 = shortened_hashtag_names[2])

Idents(my_data.hashtag) <- "HTO_classification.global"
VlnPlot(my_data.hashtag, features = "nCount_HTO", pt.size = 0.1, log = TRUE)


# First, we will remove negative cells from the object
my_data.hashtag.subset <- subset(my_data.hashtag, idents = "Negative", invert = TRUE)

# Calculate a distance matrix using HTO
hto.dist.mtx <- as.matrix(dist(t(GetAssayData(object = my_data.hashtag.subset, assay = "HTO"))))
# Calculate tSNE embeddings with a distance matrix
my_data.hashtag.subset <- RunTSNE(my_data.hashtag.subset, distance.matrix = hto.dist.mtx, perplexity = 100)
DimPlot(my_data.hashtag.subset)


# To increase the efficiency of plotting, you can subsample cells using the num.cells argument
HTOHeatmap(my_data.hashtag, assay = "HTO", ncells = 9000)

# Extract the singlets
my_data.singlet <- subset(my_data.hashtag, idents = "Singlet")

# Select the top 1000 most variable features
#my_data.singlet <- FindVariableFeatures(my_data.singlet, selection.method = "mean.var.plot")

# Scaling RNA data, we only scale the variable features here for efficiency
#my_data.singlet <- ScaleData(my_data.singlet, features = VariableFeatures(my_data.singlet))

# Run PCA
#my_data.singlet <- RunPCA(my_data.singlet, features = VariableFeatures(my_data.singlet))


# write to disk

library(data.table)
data_to_write_out <- as.data.frame(as.matrix(my_data.hashtag@meta.data))
data_to_write_out <- data_to_write_out[4:11]
fwrite(x = data_to_write_out, row.names = TRUE, file = file.path(path_output, "full-output.csv"))

# write to disk only CB and hashID
data_to_write_out <- data_to_write_out[8]
names(data_to_write_out) <- c("hashID")
fwrite(x = data_to_write_out, row.names = TRUE, file = file.path(path_output, "classification.csv"))
