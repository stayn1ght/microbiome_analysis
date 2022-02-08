# use package "microbiomeMarker" to analyse qiime2 results
# help documents https://bioconductor.org/packages/release/bioc/vignettes/microbiomeMarker/inst/doc/microbiomeMarker-vignette.html#normalization

# installation
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("microbiomeMarker")

library(microbiomeMarker)

# importing data from qiime2
otuqza_file <- "$PATH/table.qza"
taxaqza_file <- "$PATH/taxonomy.qza"
sample_file <- "$PATH/sample-metadata.tsv"

ps <- import_qiime2( # 这个函数就是导入数据的函数, 具体参数似乎可以调整, 比如可以再加tree.qza
    otu_qza = otuqza_file, taxa_qza = taxaqza_file,
    sam_tab = sample_file
)


# Diferential analysis
## Normalization 
## many different ways of normalization, tss means total sum scaling, also reffered to as "relative abundance".
## All the DA functions provides a para to specify the normalization method. We emphasize that users should specify the normalization method
##in the DA functions rather than using these normalization functions directly.

## metagenome based methods, take LEfSe method  for example

#### 
data(kostic_crc)
kostic_crc_small <- phyloseq::subset_taxa(
    kostic_crc,
    Phylum %in% c("Firmicutes")
)
mm_lefse <- run_lefse(
    kostic_crc_small,
    wilcoxon_cutoff = 0.01,
    group = "DIAGNOSIS",
    kw_cutoff = 0.01,
    multigrp_strat = TRUE,
    lda_cutoff = 4
)
#### 

# Visualization
