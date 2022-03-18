#!/usr/bin/bash

## -- NOTE: three parameters are needed,
## 1. acclist: a text file containing a list of accession IDs
## 2. data source: ena or ncbi
## 3. data format: fastq or sra

[ $# -ne 3 ] && { echo "Three parameters are required" ; echo "Usage: $0 acc_list_file data_source[ena or ncbi] data_format[fastq or sra]" ; exit 1; }

readrunfile=$1
datasource=$2
seqformat=$3

echo '--------------------------------------------------------------------'
echo $readrunfile
echo $datasource
echo $seqformat
echo '--------------------------------------------------------------------'

if [ $datasource = 'ena' ]
then
    # ena抓取数据的网页改地址了，原来的enadataget不能用了，以下是对该工具源码修改后最新版的下载方式
    cat $readrunfile | xargs -n 1 /mnt/raid6/jiayingzhu/software/conda/miniconda3/bin/python3 \
    /mnt/raid8/datarepo/software/enaBrowserTools-1.5.4/python3/enaDataGet.py -f $seqformat \
    -as /mnt/raid8/datarepo/software/enaBrowserTools-1.5.4/aspera_settings.ini -d  01_rawdata/
    #cat $readrunfile | xargs -n 1 /mnt/raid1/tools/enaBrowserTools-1.6/python3/enaDataGet -f $seqformat -as /mnt/raid1/tools/aspera_settings.ini -d  01_rawdata/
else
    #prefetch -O 01_rawdata/ --progress --force no --ascp-path '/opt/aspera/bin/ascp|/mnt/raid1/tools/asperaweb_id_dsa.openssh' --option-file $readrunfile
        sh /mnt/raid8/datarepo/scripts/download.sh $readrunfile
fi

# 2022.3.18 update
## Using the script below to download data successfully. while using -as /PATH/aspera_settints.ini
## got false. The reason still stay unsong. What's more, using xargs also got the wrong end of stick.
for line in $(cat run_acc.ls)
do 
 python3 /mnt/raid8/datarepo/software/enaBrowserTools-1.5.4/python3/enaDataGet.py -f fastq \
 -d 01_rawdata \
 $line
done

