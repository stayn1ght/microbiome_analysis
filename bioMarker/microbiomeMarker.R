# use package "microbiomeMarker" to analyse qiime2 results
# help documents https://bioconductor.org/packages/release/bioc/vignettes/microbiomeMarker/inst/doc/microbiomeMarker-vignette.html#normalization

# installation
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("microbiomeMarker")

