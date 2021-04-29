# 双端测序
import pandas as pd

df = pd.read_csv('filereport_read_run_PRJEB38986_tsv.txt', sep='\t')
sample_id = []
absolute_filepath = []
direction = []
for i in df['run_accession']:
    sample_id.append(i)
    sample_id.append(i)
    absolute_filepath.append(f'$PWD/01_rawdata/{i}/{i}_1.fastq.gz')
    absolute_filepath.append(f'$PWD/01_rawdata/{i}/{i}_2.fastq.gz')
    direction.append('forward')
    direction.append('reverse')

manifest = pd.DataFrame(list(zip(sample_id, absolute_filepath, direction)),
                        columns=['sample-id', 'absolute-filepathe', 'direction'])
manifest.to_csv('manifest.txt', index=0)
