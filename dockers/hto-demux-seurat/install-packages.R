#!/usr/bin/Rscript

# default repo
local({r <- getOption("repos")
    r["CRAN"] <- "https://cloud.r-project.org"
    options(repos=r)
})

pkgs = c('optparse')
install.packages(pkgs, repos='http://cran.us.r-project.org')
