# qiime2工作流程

## 激活qiime2环境
```bash
conda activate qiime2-2021.11
```

## 导入数据
```bash
mkdir 03_qiime_results
qiime tools import \
   --type 'SampleData[PairedEndSequencesWithQuality]' \
   --input-path manifest \
   --output-path 03_qiime_results/02_paired-end-demux.qza \
   --input-format PairedEndFastqManifestPhred33V2 
```

## 查看数据质量

```bash
qiime demux summarize \
   --i-data 03_qiime_results/02_paired-end-demux.qza \
   --o-visualization 03_qiime_results/paired-end-demux.qzv
```

## 序列质控和生成特征表
dada2降噪流程, 截取片段所用的值根据前一步质量信息来选择

```bash
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs 02_paired-end-demux.qza \
  --p-trim-left-f 13 \
  --p-trim-left-r 13 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 178 \
  --o-table 03_qiime_results/03_table.qza \
  --o-representative-sequences 03_qiime_results/04_rep-seqs.qza \
  --o-denoising-stats 03_qiime_results/05_denoising-stats.qza
```



## 特征表和特征序列汇总
结果将是一个QIIME 2对象FeatureTable[Frequency]和一个FeatureData[Sequence]，Frequency对象包含数据集中每个样本中每个唯一序列的计数（频率），Sequence对象将FeatureTable中的特征ID与序列对应。FeatureTable[Frequency]等价于QIIME 1 OTU或BIOM表，不过qiime2是以ASV为单元的表格；QIIME 2对象FeatureData[Sequence]等价于QIIME 1代表序列文件。

特性表汇总命令（feature-table summarize）将向你提供关于与每个样品和每个特性相关联的序列数量、这些分布的直方图以及一些相关的汇总统计数据的信息。特征表序列表格feature-table tabulate-seqs命令将提供特征ID到序列的映射。

这里使用的metadata是用了manifest，但是manifest文件中实际上没有录入表型信息，需要对metadata.tsv文件进行处理作为metadata信息进行处理

```bash
qiime feature-table summarize \
  --i-table 03_qiime_results/03_table.qza \
  --o-visualization 03_qiime_results/table.qzv \
  --m-sample-metadata-file meta
  
qiime feature-table tabulate-seqs \
  --i-data 03_qiime_results/04_rep-seqs.qza \
  --o-visualization 03_qiime_results/rep-seqs.qzv
```
## feature table 过滤


## 物种组成分析
这个过程的第一步是为FeatureData[Sequence]的序列进行物种注释。

metadata tabulate命令将id与数据相对应

```bash
qiime feature-classifier classify-sklearn \
  --i-classifier /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/02_classifier/01* \
  --i-reads 03_qiime_results/04_rep-seqs.qza \
  --o-classification 03_qiime_results/06_taxonomy.qza
  
qiime metadata tabulate \
  --m-input-file 03_qiime_results/06_taxonomy.qza \
  --o-visualization 03_qiime_results/taxonomy.qzv
```

## 可视化，物种堆叠柱状图
```bash
qiime taxa barplot \
  --i-table 03_qiime_results/03_table.qza \
  --i-taxonomy 03_qiime_results/06_taxonomy.qza \
  --m-metadata-file meta \
  --o-visualization 03_qiime_results/taxa-bar-plots.qzv
```

## 生成丰度表
[利用biom生成丰度表](https://github.com/iceQHdrop/16s_Taxonomic-analysis#%E5%88%A9%E7%94%A8biom%E5%AE%8C%E6%88%90%E4%B8%B0%E5%BA%A6%E8%A1%A8)
