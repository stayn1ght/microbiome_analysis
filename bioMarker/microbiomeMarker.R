# use package "microbiomeMarker" to analyse qiime2 results
# [help documents](https://bioconductor.org/packages/release/bioc/vignettes/microbiomeMarker/inst/doc/microbiomeMarker-vignette.html)

# installation
## the newest version of BiocManager is only available on R 4.1
## use R on waston for the analysis below 
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}

BiocManager::install("microbiomeMarker")


library(microbiomeMarker)
library(ggplot2)
# importing data from qiime2
# setwd("/mnt/raid7/mingyuwang/gut_fungus/PRJNA698272/")
otuqza_file <- "03_qiime_results/03_table.qza"
taxaqza_file <- "03_qiime_results/06_taxonomy.qza"
sample_file <- "meta"

ps <- import_qiime2( # 这个函数就是导入数据的函数, 具体参数似乎可以调整, 比如可以再加tree.qza
    otu_qza = otuqza_file, taxa_qza = taxaqza_file,
    sam_tab = sample_file
) # 这里应该注意要导入的metadata，应该是符合qiime要求的格式


# Diferential analysis
## Normalization 
## many different ways of normalization, tss means total sum scaling, also reffered to as "relative abundance".
## All the DA functions provides a para to specify the normalization method. We emphasize that users should specify the normalization method
##in the DA functions rather than using these normalization functions directly.

## metagenome based methods, LEfSe method. There are also other methods.

#### 

mm_lefse <- run_lefse(
    ps,
    wilcoxon_cutoff = 0.05,
    group = "label",
    kw_cutoff = 0.05,
    multigrp_strat = TRUE,
    lda_cutoff = 2
)
#### 

# Visualization
plot_ef_bar(mm_lefse) +
  labs(x = 'LDA score (log10)')

# write the lda score to table
lda_table <- marker_table(mm_lefse)
lda_df <- data.frame(lda_table)
write.csv(lda_df, file="05_lefse_analysis/markers.csv")