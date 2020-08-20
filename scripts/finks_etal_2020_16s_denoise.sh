#!/bin/bash
#$ -N qiime2_denoise_fwd
#$ -m beas
#$ -q mic,pub8i
#$ -pe openmp 64

# Qiime2 denoise, and diversity metrics for bacteria.

cd /bio/sfinks/lrgce/16s/final

module load anaconda/3.6-4.3.1
source activate qiime2-2018.11

qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux.qza \
  --p-n-threads 64 \
  --p-trim-left 5 \
  --p-trunc-len 275 \
  --o-representative-sequences rep-seqs.qza \
  --o-table table.qza \
  --o-denoising-stats denoising-stats.qza

qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

qiime feature-classifier classify-sklearn \
  --i-classifier /bio/sfinks/lrgce/16s/515-926classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

 qiime taxa filter-seqs \
  --i-sequences rep-seqs.qza \
  --i-taxonomy taxonomy.qza \
  --p-include p__ \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-sequences rep-seqs_filtered.qza

 qiime taxa filter-table \
  --i-table table.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --p-include p__ \
  --o-filtered-table table_filtered.qza

qiime feature-table summarize \
  --i-table table_filtered.qza \
  --o-visualization table_filtered.qzv \
  --m-sample-metadata-file metadata.tsv
 
 qiime feature-table tabulate-seqs \
  --i-data rep-seqs_filtered.qza \
  --o-visualization rep-seqs_filtered.qzv
 
qiime alignment mafft \
  --i-sequences rep-seqs_filtered.qza \
  --o-alignment aligned-rep-seqs.qza
  
qiime alignment mask \
  --i-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza
  
qiime phylogeny fasttree \
  --i-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza
  
qiime phylogeny midpoint-root \
  --i-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza
 
qiime taxa barplot \
  --i-table table_filtered.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file metadata_rarified.tsv \
  --o-visualization taxa-bar-plots-final-rar.qzv
 
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table table_filtered.qza \
  --p-sampling-depth 5,000 \
  --m-metadata-file metadata.tsv \
  --output-dir core-metrics-results
  
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization core-metrics-results/faith-pd-group-significance.qzv
  
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file metadata.tsv \
  --o-visualization core-metrics-results/evenness-group-significance.qzv
  
 qiime diversity alpha-rarefaction \
  --i-table table_filtered.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 1090 \
  --p-iterations 300 \
  --m-metadata-file metadata.tsv \
  --o-visualization alpha-rarefaction.qzv 

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column site \
  --o-visualization core-metrics-results/unweighted-unifrac-site-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column water_treatment \
  --o-visualization core-metrics-results/unweighted-unifrac-water_treatment-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column nitrogen_treatment \
  --o-visualization core-metrics-results/unweighted-unifrac-nitrogen_treatment-significance.qzv \
  --p-pairwise
  
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata.tsv \
  --m-metadata-column year \
  --o-visualization core-metrics-results/unweighted-unifrac-year-significance.qzv \
  --p-pairwise
  