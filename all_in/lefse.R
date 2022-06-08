# STEP5 lefse analysis for each bioproject with at least two phenotypes

## 1. importing data from qiime2
otuqza_file <- "03_qiime_results/03_table.qza"
taxaqza_file <- "03_qiime_results/06_taxonomy.qza"
sample_file <- "meta" # curated metadata file is needed here, with mesh id of disease. Error: because the function sample_names() takes 'sampleid' column as sample name, using the file 'curated metadata will make mistakes.

ps <- import_qiime2( # 这个函数就是导入数据的函数, 具体参数似乎可以调整, 比如可以再加tree.qza
    otu_qza = otuqza_file, taxa_qza = taxaqza_file,
    sam_tab = sample_file
) # 这里应该注意要导入的metadata，应该是符合qiime要求的格式

## 2. calculate LDA score and get the marker chart
mm_lefse <- run_lefse(
    ps,
    wilcoxon_cutoff = 0.05,
    group = "label", # need change, match the steps of making curated metadata.
    kw_cutoff = 0.05,
    multigrp_strat = TRUE,
    lda_cutoff = 2,
    taxa_rank = "Genus"
)
plot_ef_bar(mm_lefse) +
  labs(x = 'LDA score')

disease <- read.csv("curated_metadata.csv", header = TRUE) %>% select(phenotype) %>% 
    left_join(mesh.id, by = "phenotype") %>%
    select(disease) %>% distinct() %>% t()
lda_table <- marker_table(mm_lefse) %>% data.frame() %>% select(-padj) %>% rename(comparison_result = enrich_group) %>% 
    bind_cols(phenotype1 = disease[1], phenotype2 = disease[2], project_id = readline("input project id:")) 


write.csv(lda_table, file = "05_lefse_analysis/markers.csv", row.names = FALSE)

## 3. lefse summary
