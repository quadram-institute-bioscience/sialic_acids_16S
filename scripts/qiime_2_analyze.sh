#!/bin/bash
set -euo pipefail

# This script requires
# *  QIIME 2018.8
# *  A Qiime 2 classifier artifact:
DB=/qib/platforms/Informatics/telatin/db/16S/silva132_NJ_classifier.qza

# Parameters
INPUT='';
MAPPING='';
CATEGORY='Treatment'
OUTPUT_DIR='./qiime2_out/';
TRIM_LEFT=10
TRUNC_LEN=0
MAX_EE=1.0
THREADS=4
DEPTH=10000
NUMERIC=''

echo "USAGE:
  process_se.sh [options] [-o OutDir=$OUTPUT_DIR] -i DemuxReadsQiime2Artifact.qza 
  -d      Depth, int=$DEPTH
  -m      Mapping file, str ***
  -c      Category, str=$CATEGORY
  -t      Threads, int=$THREADS
  -e      Max EE, float=$MAX_EE
  -l      Trunc len, int=$TRUNC_LEN
  -n      Numeric category (FALSE)
  -v      Verbose
";
while getopts d:e:t:o:i:m:l:c:n:vj option
do
        case "${option}"
                in
			c) CATEGORY=${OPTARG};;
			n) NUMERIC=1;;
			d) DEPTH=${OPTARG};;
			m) MAPPING=${OPTARG};;
                        o) OUTPUT_DIR=${OPTARG};;
                        i) INPUT=${OPTARG};;
			l) TRUNC_LEN=${OPTARG};;
                        v) VERBOSE=1;;
			t) THREADS=${OPTARG};;
			e) MAX_EE=${OPTARG};;
                        ?) echo " Wrong parameter $OPTARG";;
         esac
done
shift "$(($OPTIND -1))"


if [ ! -d "$OUTPUT_DIR" ]; then
	echo "[0] Creating output directory $OUTPUT_DIR";
	mkdir "$OUTPUT_DIR";
fi

if [ ! -e "$INPUT" ]; then
	echo "Unable to find input file <$INPUT>"
	exit 1
fi

if [ ! -e "$MAPPING" ]; then
        echo "Unable to find *metadata* file <$MAPPING>"
        exit 1
fi

if [ ! -e "$DB" ]; then
        echo "Unable to find *DB* file <$DB>"
        exit 1
fi



if [ ! -e "$OUTPUT_DIR/rep-seqs.qza" ]; then
echo " - Dada2"
qiime dada2 denoise-single \
  --i-demultiplexed-seqs "$INPUT" \
  --p-trim-left $TRIM_LEFT \
  --p-trunc-len $TRUNC_LEN \
  --p-n-threads  $THREADS \
  --p-max-ee $MAX_EE \
  --o-representative-sequences "$OUTPUT_DIR/rep-seqs.qza" \
  --o-table "$OUTPUT_DIR/table.qza" \
  --o-denoising-stats "$OUTPUT_DIR/stats.qza"
fi

if [ ! -e "$OUTPUT_DIR/rep-seqs.qzv" ]; then
echo " - Table summarize [Metadata]"
qiime feature-table summarize \
  --i-table "$OUTPUT_DIR/table.qza" \
  --o-visualization "$OUTPUT_DIR/table.qzv" \
  --m-sample-metadata-file "$MAPPING"

qiime feature-table tabulate-seqs \
  --i-data "$OUTPUT_DIR/rep-seqs.qza" \
  --o-visualization "$OUTPUT_DIR/rep-seqs.qzv"
fi

if [ ! -e "$OUTPUT_DIR/rooted-tree.qza" ]; then
echo " - Phylogeny"
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences "$OUTPUT_DIR/rep-seqs.qza" \
  --o-alignment "$OUTPUT_DIR/aligned-rep-seqs.qza" \
  --o-masked-alignment "$OUTPUT_DIR/masked-aligned-rep-seqs.qza" \
  --o-tree "$OUTPUT_DIR/unrooted-tree.qza" \
  --o-rooted-tree "$OUTPUT_DIR/rooted-tree.qza"
fi

if [ ! -d "$OUTPUT_DIR/core-metrics-results/" ]; then
echo " - Core [Metadata,Depth]"
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "$OUTPUT_DIR/rooted-tree.qza" \
  --i-table "$OUTPUT_DIR/table.qza" \
  --p-sampling-depth $DEPTH \
  --m-metadata-file "$MAPPING" \
  --output-dir "$OUTPUT_DIR/core-metrics-results"
fi

# ALPHA GROUP SIGNIFICANCE: https://docs.qiime2.org/2018.8/tutorials/moving-pictures/#alpha-and-beta-diversity-analysis

if [ ! -e "$OUTPUT_DIR/core-metrics-results/evenness-group-significance.qzv" ]; then
echo " - Alpha-group-significance [Mapping]"
qiime diversity alpha-group-significance \
      --i-alpha-diversity "$OUTPUT_DIR/core-metrics-results/faith_pd_vector.qza" \
      --m-metadata-file "$MAPPING" \
      --o-visualization "$OUTPUT_DIR/core-metrics-results/faith-pd-group-significance.qzv"

qiime diversity alpha-group-significance \
      --i-alpha-diversity "$OUTPUT_DIR/core-metrics-results/evenness_vector.qza" \
      --m-metadata-file "$MAPPING" \
      --o-visualization "$OUTPUT_DIR/core-metrics-results/evenness-group-significance.qzv"
fi

if [ ! -e "$OUTPUT_DIR/core-metrics-results/unweighted-unifrac-$CATEGORY-significance.qzv" ]; then
echo " - Beta-group-significance [Metadata]"
qiime diversity beta-group-significance \
      --i-distance-matrix "$OUTPUT_DIR/core-metrics-results/unweighted_unifrac_distance_matrix.qza" \
      --m-metadata-file "$MAPPING" \
      --m-metadata-column "$CATEGORY" \
      --o-visualization "$OUTPUT_DIR/core-metrics-results/unweighted-unifrac-$CATEGORY-significance.qzv" \
      --p-pairwise

fi

check=`echo "$CATEGORY" | grep -E ^\-?[0-9]*\.?[0-9]+$`
if [ "$NUMERIC" != '' ]; then
    echo " - Emperor"
    qiime emperor plot \
	--i-pcoa "$OUTPUT_DIR/core-metrics-results/unweighted_unifrac_pcoa_results.qza" \
	--m-metadata-file "$MAPPING" \
	--p-custom-axes "$CATEGORY" \
	--o-visualization "$OUTPUT_DIR/core-metrics-results/unweighted-unifrac-emperor-$CATEGORY.qzv"
else 
	echo " - Emperor SKIPPED"
fi

# TAXONOMIC ANALYSIS: https://docs.qiime2.org/2018.8/tutorials/moving-pictures/#taxonomic-analysis

if [[ ! -e "$OUTPUT_DIR/taxonomy.qza" ]]; then
echo " - Taxonomy $DB"
qiime feature-classifier classify-sklearn \
  --i-classifier "$DB" \
  --i-reads "$OUTPUT_DIR/rep-seqs.qza" \
  --o-classification "$OUTPUT_DIR/taxonomy.qza"

qiime metadata tabulate \
  --m-input-file "$OUTPUT_DIR/taxonomy.qza" \
  --o-visualization "$OUTPUT_DIR/taxonomy.qzv"
fi

if [[ ! -e "$OUTPUT_DIR/taxa-bar-plots.qzv" ]]; then
echo " - Barplot"
qiime taxa barplot \
  --i-table "$OUTPUT_DIR/table.qza" \
  --i-taxonomy "$OUTPUT_DIR/taxonomy.qza" \
  --m-metadata-file "$MAPPING" \
  --o-visualization "$OUTPUT_DIR/taxa-bar-plots.qzv"
fi
