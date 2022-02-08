# use package "microbiomeMarker" to analyse qiime2 results
# help documents https://bioconductor.org/packages/release/bioc/vignettes/microbiomeMarker/inst/doc/microbiomeMarker-vignette.html#normalization

# installation
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("microbiomeMarker")

library(microbiomeMarker)

# importing data
otuqza_file <- system.file(
    "extdata", "table.qza",
    package = "microbiomeMarker"
)
taxaqza_file <- system.file(
    "extdata", "taxonomy.qza",
    package = "microbiomeMarker"
)
sample_file <- system.file(
    "extdata", "sample-metadata.tsv",
    package = "microbiomeMarker"
)
treeqza_file <- system.file(
    "extdata", "tree.qza",
    package = "microbiomeMarker"
)

ps <- import_qiime2(
    otu_qza = otuqza_file, taxa_qza = taxaqza_file,
    sam_tab = sample_file, tree_qza = treeqza_file
)
ps

# Diferential analysis
## Normalization 

####
# take tss as example
norm_tss(ps)
#> phyloseq-class experiment-level object
#> otu_table()   OTU Table:         [ 770 taxa and 34 samples ]
#> sample_data() Sample Data:       [ 34 samples by 9 sample variables ]
#> tax_table()   Taxonomy Table:    [ 770 taxa by 7 taxonomic ranks ]
#> phy_tree()    Phylogenetic Tree: [ 770 tips and 768 internal nodes ]

normalize(ps, method = "TSS")
#> phyloseq-class experiment-level object
#> otu_table()   OTU Table:         [ 770 taxa and 34 samples ]
#> sample_data() Sample Data:       [ 34 samples by 9 sample variables ]
#> tax_table()   Taxonomy Table:    [ 770 taxa by 7 taxonomic ranks ]
#> phy_tree()    Phylogenetic Tree: [ 770 tips and 768 internal nodes ]

data(kostic_crc)
mm_test <- normalize(kostic_crc, method = "CPM") %>%
    run_lefse(
        wilcoxon_cutoff = 0.01,
        norm = "none", # must be "none" since the input has been normalized
        group = "DIAGNOSIS",
        kw_cutoff = 0.01,
        multigrp_strat = TRUE,
        lda_cutoff = 4
    )
# equivalent to
run_lefse(
    wilcoxon_cutoff = 0.01,
    norm = "CPM",
    group = "DIAGNOSIS",
    kw_cutoff = 0.01,
    multigrp_strat = TRUE,
    lda_cutoff = 4
)
####

## 
