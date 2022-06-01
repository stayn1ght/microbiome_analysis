# microbiome_analysis in brief
qiime2 pipeline are used for human gut microbiome analysis

incuding 16s ITS 18s sequencing data

interactive plot is used for prevalence and abundance analysis.

[biomarker](bioMarker/microbiomeMarker.R) the script are used to conduct LEfSe analysis using R package 'microbiomeMarker'

[qiime2_analyse]() qiime2 analysis pipeline for ITS and 18S sequencing data.

=￣ω￣=

# analysis pipeline
### download data
  including raw data and metadata prepared
### curate metadata
  here we introduce MeSH to curate disease
### qiime analysis
  get the genus table, and process it to relative abundance and long format
  
  we introduce ncbi taxonomy id to annotate the taxon(genus)
### lefse analysis

### prevalence vs. abundance
