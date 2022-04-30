# PRJDB7616 is used as an example
# In this bioproject, the downloaded sequence from NCBI Bioproject seems to be merged reads, with the whole length longer than 900bp. 
# Because of the very high quanlity of these sequences and that the sequences are merged reads, denoising steps should be eliminished.

# above all, using the scripts in qiime2_pipeline.md to import data as qza file.

qiime vsearch dereplicate-sequences \
  --i-sequences 03_qiime_results/02_single-end-demux.qza \
  --o-dereplicated-table 03_qiime_results/03_table.qza \
  --o-dereplicated-sequences 03_qiime_results/04_rep-seqs.qza

# next step is de novo clustering of the sequences, aiming to make it faster to classify.
qiime vsearch cluster-features-de-novo \
  --i-table 03_qiime_results/03_table.qza \
  --i-sequences 03_qiime_results/04_rep-seqs.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table 03_qiime_results/table-dn-99.qza \
  --o-clustered-sequences 03_qiime_results/rep-seqs-dn-99.qza


time qiime feature-classifier classify-sklearn \
  --i-classifier /mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/02_classifier/01* \
  --i-reads 03_qiime_results/rep-seqs-dn-99.qza \
  --o-classification 03_qiime_results/06_taxonomy.qza
  
time qiime metadata tabulate \
  --m-input-file 03_qiime_results/06_taxonomy.qza \
  --o-visualization 03_qiime_results/taxonomy.qzv

time qiime taxa barplot \
  --i-table 03_qiime_results/03_table.qza \
  --i-taxonomy 03_qiime_results/06_taxonomy.qza \
  --m-metadata-file meta \
  --o-visualization 03_qiime_results/taxa-bar-plots.qzv
