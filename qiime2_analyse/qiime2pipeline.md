# 激活qiime2环境
conda activate qiime2-2021.11

# 导入数据
qiime tools import \
   --type 'SampleData[PairedEndSequencesWithQuality]' \
   --input-path manifest \
   --output-path 03_qiime_results/02_paired-end-demux.qza \
   --input-format PairedEndFastqManifestPhred33V2 

# 查看数据质量
qiime demux summarize \
   --i-data 03_qiime_results/02_paired-end-demux.qza \
   --o-visualization 03_qiime_results/paired-end-demux.qzv

# 序列质控和生成特征表
## 降噪, 截取片段所用的值根据前一步质量信息来选择
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs 02_paired-end-demux.qza \
  --p-trim-left-f 13 \
  --p-trim-left-r 13 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 178 \
  --o-table 03_qiime_results/03_table.qza \
  --o-representative-sequences 03_qiime_results/04_rep-seqs.qza \
  --o-denoising-stats 03_qiime_results/05_denoising-stats.qza

# 特征表和特征序列汇总
## feature-table tabulate-seqs命令将提供特征ID到序列的映射
## 这里使用的metadata是用了manifest，但是manifest文件中实际上没有录入表型信息
## 需要对metadata.tsv文件进行处理作为metadata信息进行处理
qiime feature-table summarize \
  --i-table 03_qiime_results/03_table.qza \
  --o-visualization 03_qiime_results/table.qzv \
  --m-sample-metadata-file meta
  
qiime feature-table tabulate-seqs \
  --i-data 03_qiime_results/04_rep-seqs.qza \
  --o-visualization 03_qiime_results/rep-seqs.qzv

# 物种组成分析
## metadata tabulate将id与数据相对应
qiime feature-classifier classify-sklearn \
  --i-classifier /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/02_classifier/01* \
  --i-reads 03_qiime_results/04_rep-seqs.qza \
  --o-classification 03_qiime_results/06_taxonomy.qza
  
qiime metadata tabulate \
  --m-input-file 03_qiime_results/06_taxonomy.qza \
  --o-visualization 03_qiime_results/taxonomy.qzv


# 可视化，物种堆叠柱状图
qiime taxa barplot \
  --i-table 03_qiime_results/03_table.qza \
  --i-taxonomy 03_qiime_results/06_taxonomy.qza \
  --m-metadata-file meta \
  --o-visualization 03_qiime_results/taxa-bar-plots.qzv

