#!/usr/bin/Rscript

# default repo
local({r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos=r)
})

pkgs = c('optparse')
install.packages(pkgs, repos='http://cran.us.r-project.org')

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# BiocManager::install("rhdf5")
# BiocManager::install("GenomicRanges")
# BiocManager::install("edgeR")

source("https://bioconductor.org/biocLite.R")
biocLite()

source("https://bioconductor.org/biocLite.R")
biocLite(c("Seurat"))

