#!/bin/bash
#$ -N qiime2_demux_paired_trimmed
#$ -m beas
#$ -q mic,pub8i
#$ -pe openmp 64

cd /bio/sfinks/lrgce/16s

module load anaconda/2.7-4.3.1
source activate qiime2-2018.4

qiime tools import \
   --type EMPPairedEndSequences \
   --input-path raw-data \
   --output-path imported_data.qza

qiime demux emp-paired \
  --m-barcodes-file metadata.tsv \
  --m-barcodes-column barcodes \
  --i-seqs imported_data.qza \
  --o-per-sample-sequences demux.qza

qiime demux summarize \
  --i-data demux.qza \
  --o-visualization demux.qzv


