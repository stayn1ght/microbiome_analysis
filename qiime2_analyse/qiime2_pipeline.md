# qiime2工作流程

## preparations
### download_data
```bash
awk -F "," '{print $1}' SraRunTable.txt > run_acc.ls
sh /mnt/raid8/datarepo/scripts/01_download_rawdata.sh *.ls   ena   fastq
rm *.ls

```

### make manifest for improting data
```bash
# pair end sequence
ls 01_rawdata > temp1
ls 01_rawdata/SRR*/*_1.fastq* > temp2
ls 01_rawdata/SRR*/*_2.fastq* > temp3
sed -i 's/^/$PWD\//' temp2
sed -i 's/^/$PWD\//' temp3
Rscript /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/rscript1
rm temp* 

```

```bash
# single end sequence
ls 01_rawdata > temp1
ls 01_rawdata/ERR*/*.fastq* > temp2
sed -i 's/^/$PWD\//' temp2
Rscript /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/rscript2_singleend
rm temp*

```


## 激活qiime2环境
```bash
conda activate qiime2-2021.11

```

## 导入数据
```bash
mkdir 03_qiime_results
time qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest \
  --output-path 03_qiime_results/02_paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33V2

```

```bash
# single end sequence
mkdir 03_qiime_results
time qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest \
  --output-path 03_qiime_results/02_single-end-demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

```

## 查看数据质量

```bash
time qiime demux summarize \
  --i-data 03_qiime_results/02_paired-end-demux.qza \
  --o-visualization 03_qiime_results/paired-end-demux.qzv

```

```bash
# for single end sequence
time qiime demux summarize \
  --i-data 03_qiime_results/02_single-end-demux.qza \
  --o-visualization 03_qiime_results/single-end-demux.qzv

```
## 序列质控和生成特征表
dada2降噪流程, 截取片段所用的值根据前一步质量信息来选择

```bash
time qiime dada2 denoise-paired \
  --i-demultiplexed-seqs 03_qiime_results/02_paired-end-demux.qza \
  --o-table 03_qiime_results/03_table.qza \
  --o-representative-sequences 03_qiime_results/04_rep-seqs.qza \
  --o-denoising-stats 03_qiime_results/05_denoising-stats.qza \
  --p-trim-left-f 13 \
  --p-trim-left-r 13 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 178 \
```

```bash
# for single end sequence
time qiime dada2 denoise-single \
  --i-demultiplexed-seqs 03_qiime_results/02_paired-end-demux.qza \
  --o-table 03_qiime_results/03_table.qza \
  --o-representative-sequences 03_qiime_results/04_rep-seqs.qza \
  --o-denoising-stats 03_qiime_results/05_denoising-stats.qza \
  --p-trim-left 13 \
  --p-trunc-len 150
```

d对特征表统计进行可视化
```bash
qiime metadata tabulate \
  --m-input-file 03_qiime_results/05_denoising-stats.qza \
  --o-visualization 03_qiime_results/denoising-stats.qzv
  
```


## 特征表和特征序列汇总
结果将是一个QIIME 2对象FeatureTable[Frequency]和一个FeatureData[Sequence]，Frequency对象包含数据集中每个样本中每个唯一序列的计数（频率），Sequence对象将FeatureTable中的特征ID与序列对应。FeatureTable[Frequency]等价于QIIME 1 OTU或BIOM表，不过qiime2是以ASV为单元的表格；QIIME 2对象FeatureData[Sequence]等价于QIIME 1代表序列文件。

特性表汇总命令（feature-table summarize）将向你提供关于与每个样品和每个特性相关联的序列数量、这些分布的直方图以及一些相关的汇总统计数据的信息。特征表序列表格feature-table tabulate-seqs命令将提供特征ID到序列的映射。

这里使用的metadata是用了manifest，但是manifest文件中实际上没有录入表型信息，需要对metadata.tsv文件进行处理作为metadata信息进行处理

```bash
time qiime feature-table summarize \
  --i-table 03_qiime_results/03_table.qza \
  --o-visualization 03_qiime_results/table.qzv \
  --m-sample-metadata-file meta
  
time qiime feature-table tabulate-seqs \
  --i-data 03_qiime_results/04_rep-seqs.qza \
  --o-visualization 03_qiime_results/rep-seqs.qzv
```
## feature table 过滤


## 物种组成分析
这个过程的第一步是为FeatureData[Sequence]的序列进行物种注释。

metadata tabulate命令将id与数据相对应

```bash
time qiime feature-classifier classify-sklearn \
  --i-classifier /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/02_classifier/01* \
  --i-reads 03_qiime_results/04_rep-seqs.qza \
  --o-classification 03_qiime_results/06_taxonomy.qza
  
time qiime metadata tabulate \
  --m-input-file 03_qiime_results/06_taxonomy.qza \
  --o-visualization 03_qiime_results/taxonomy.qzv
```

## 可视化，物种堆叠柱状图
```bash
time qiime taxa barplot \
  --i-table 03_qiime_results/03_table.qza \
  --i-taxonomy 03_qiime_results/06_taxonomy.qza \
  --m-metadata-file meta \
  --o-visualization 03_qiime_results/taxa-bar-plots.qzv
```

## 生成丰度表
[利用biom生成丰度表](https://github.com/iceQHdrop/16s_Taxonomic-analysis#%E5%88%A9%E7%94%A8biom%E5%AE%8C%E6%88%90%E4%B8%B0%E5%BA%A6%E8%A1%A8)

得到物种注释并产生biom表
```bash
qiime tools export \
  --input-path 03_qiime_results/06_taxonomy.qza \
  --output-path taxa

sed -i -e '1 s/Feature/#Feature/' -e '1 s/Taxon/taxonomy/' taxa/taxonomy.tsv

qiime tools export \
  --input-path 03_qiime_results/03_table.qza \
  --output-path table_exported

```
生成丰度表
```bash
biom add-metadata \
  -i table_exported/feature-table.biom \
  -o table_exported/feature-table_w_tax.biom \
  --observation-metadata-fp taxa/taxonomy.tsv \
  --sc-separated taxonomy

biom convert \
  -i table_exported/feature-table_w_tax.biom \
  -o table_exported/feature-table_w_tax.txt \
  --header-key taxonomy \
  --to-tsv

sed -i '1d' feature-table_w_tax.txt

```
得到最终的丰度表
```bash
python adjust-abundance.py \
  -i feature-table_w_tax.txt \
  -o abundance.csv

```