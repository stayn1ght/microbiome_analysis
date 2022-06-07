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
    lda_cutoff = 2
)
plot_ef_bar(mm_lefse) +
  labs(x = 'LDA score')

disease <- read.csv("curated_metadata.csv", header = TRUE) %>% select(phenotype) %>% 
    left_join(mesh.id, by = "phenotype") %>%
    select(disease) %>% distinct() %>% t()
lda_table <- marker_table(mm_lefse) %>% data.frame() %>% select(-padj) %>% rename(comparison_result = enrich_group) %>% 
    bind_cols(project_id = "PRJEB42375", 
              phenotype1 = disease[1], phenotype2 = disease[2])

write.csv(lda_table, file = "05_lefse_analysis/markers.csv", row.names = FALSE)
### the column feature can be edit by the code in STEP2
setwd("/mnt/raid7/mingyuwang/gut_fungus")
list.files(pattern = "markers.csv", recursive = TRUE)

write.csv(lda_table["feature"], file = "temp_taxon_name", row.names = FALSE)
#### bash command used for process the taxon_name -------------
# 这里还不能用STEP2里面的那套，因为lefse的结果
sed -i "s/\"//g" temp_taxon_name # 名字里面的引号先去掉
sed -i "s/|[a-z]\_\_/,/g" temp_taxon_name 
sed -i 's/k\_\_//g' temp_taxon_name ## 把 k__ p__ 这样的前缀去掉
sed -i "s/\_/ /g" temp_taxon_name ## 把菌名中的下划线换成空格
sed -i 's/\.  /,  /g' temp_taxon_name
sed -i "1d" temp_taxon_name
####
 
taxon <- read.table( "temp_taxon_name", header=FALSE, sep=",")
colnames(taxon) <- c("kingdom", "phylum", "class", "order", "family", "genus") 
write.table(distinct(taxon["genus"]), file="temp_genus_name", row.names=FALSE)

### bash conmmand are used here
sed -i "s/\"//g" temp_genus_name
sed -i "1d" temp_genus_name

### get ncbi taxon id

### attach ncbi taxon id to the abundance table
### bash used ------------
sed -i "s/\t|\t/,/g" tax_report.txt  ## the original file is separated by |, which is difficult to deal using R.
sed -i 's/"//g' tax_report.txt       ## the " in the file get the read table wrong.

### attach
ncbi.genus.id <- read.csv("tax_report.txt", header=TRUE) %>% filter(name != "") %>% distinct() %>% rename(genus = name)
  # some taxon are not assigned to certan species, as a result of which the name is empty.
taxon.id.not.found <- filter(ncbi.genus.id, code == 3) %>% select(genus) %>% distinct()

## 4. lefse summary -------------