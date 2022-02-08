# use package "microbiomeMarker" to analyse qiime2 results
# help documents https://bioconductor.org/packages/release/bioc/vignettes/microbiomeMarker/inst/doc/microbiomeMarker-vignette.html#normalization

# installation
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("microbiomeMarker")

library(microbiomeMarker)

# importing data
otuqza_file <- "$PATH/table.qza"
taxaqza_file <- "$PATH/taxonomy.qza"
sample_file <- "$PATH/sample-metadata.tsv"

ps <- import_qiime2( # 这个函数就是导入数据的函数, 具体参数似乎可以调整, 比如可以再加tree.qza
    otu_qza = otuqza_file, taxa_qza = taxaqza_file,
    sam_tab = sample_file
)


# Diferential analysis
## Normalization 
## normalization is perior to after diferential analysis which could be devided into three methods a) simple statistical tests; b) RNA-seq based methods; c) metagenomic based methods
## many different ways of normalization, tss means total sum scaling, also reffered to as "relative abundance".

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

mm_lefse
#> microbiomeMarker-class inherited from phyloseq-class
#> normalization method:              [ CPM ]
#> microbiome marker identity method: [ lefse ]
#> marker_table() Marker Table:       [ 12 microbiome markers with 5 variables ]
#> otu_table()    OTU Table:          [ 276 taxa and  177 samples ]
#> sample_data()  Sample Data:        [ 177 samples by  71 sample variables ]
#> tax_table()    Taxonomy Table:     [ 276 taxa by 1 taxonomic ranks ]
head(marker_table(mm_lefse))
#>                                                                                                                         feature
#> marker1                                             k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Ruminococcaceae
#> marker2                         k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Ruminococcaceae|g__Faecalibacterium
#> marker3 k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Ruminococcaceae|g__Faecalibacterium|s__Faecalibacterium_s__
#> marker4                                                                                 k__Bacteria|p__Firmicutes|c__Clostridia
#> marker5                                                                k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales
#> marker6                      k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Ruminococcaceae|g__Ruminococcaceae_g__
#>         enrich_group   ef_lda       pvalue         padj
#> marker1      Healthy 4.975815 7.154793e-05 7.154793e-05
#> marker2      Healthy 4.852349 5.914547e-04 5.914547e-04
#> marker3      Healthy 4.850535 6.043983e-04 6.043983e-04
#> marker4      Healthy 4.639973 7.176046e-04 7.176046e-04
#> marker5      Healthy 4.639973 7.176046e-04 7.176046e-04
#> marker6      Healthy 4.233960 6.990210e-03 6.990210e-03

#### 

