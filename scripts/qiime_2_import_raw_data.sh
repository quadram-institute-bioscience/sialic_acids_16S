#!/bin/bash

# This scripts import a directory containing raw reads produced by an Illumina Single-End or
# Paired-End sequencing to be analyzed using Qiime 2. The output is a Qiime 2 artifact

set -euo pipefail
VERBOSE=0
PHRED=33
LIB='Single';
PAIRED='';

echo "USAGE:
  import_directory.sh [options] [-o OUTPUT BASE] -i directory 

  -j      Quality encoding is Phred64 instead of Phred33
  -v      Verbose
";

while getopts o:i:vj option
do
        case "${option}"
                in
                        o) OUTPUT=${OPTARG};;
                        i) INPUT_DIR=${OPTARG};;
                        v) VERBOSE=1;;
			j) PHRED=64;;
                        ?) echo " Wrong parameter $OPTARG";;
         esac
done
shift "$(($OPTIND -1))"

# Check if input directory is present
if [ -z ${INPUT_DIR+x} ]; then
	echo " ERROR: Missing input directory (-i INPUT_DIR)"
	exit;
fi
INPUT_DIR=$(readlink -f "$INPUT_DIR");

# Set output artifact to DIRNAME.qza, if not user supplied with "-o NAME"
if [ -z ${OUTPUT+x} ]; then
	OUTPUT="$INPUT_DIR.qza"
fi

# This script will generate a maniferst file (see Qiime 2 docs)
MANIFEST="$OUTPUT.manifest"

# Print verbose init
if [ $VERBOSE -eq 1 ]; then
	echo "
	Input dir: $INPUT_DIR
	Manifest:  $MANIFEST
	Output:    $OUTPUT.qza
	Format:    Phred$PHRED
	";
fi

# Check if output artifact is already present and die
if [ -e "$OUTPUT.qza" ]; then
	echo " ERROR: output file found ($OUTPUT.qza)"
	exit 2;
fi

# Manifest header
echo "sample-id,absolute-filepath,direction" > $MANIFEST

# Add fastq files to the Manifest file
for FASTQ_FILE in $(find $INPUT_DIR -type f ! -size 0 | sort);
do
	if [[ $FASTQ_FILE =~ '_R1' ]]; then
		STRAND='forward'
	elif [[ $FASTQ_FILE =~ '_R2' ]]; then

	    	LIB='Paired'
		PAIRED='PairedEnd'

		STRAND='reverse'
	else
		echo " ERROR: File '$FASTQ_FILE' not strand tagged (_R1 or _R2)"
		exit;
	fi
	NAME=$(basename $FASTQ_FILE | cut -f1 -d_);
        echo "$NAME,$FASTQ_FILE,$STRAND" >> $MANIFEST
	if [ $VERBOSE -eq 1 ]; then
		echo "Adding $FASTQ_FILE ($NAME, $STRAND)"
	fi
done

# Run the actual qiime command
echo -n " Importing... "
qiime tools import \
    --type SampleData[${PAIRED}SequencesWithQuality] \
    --input-path $MANIFEST \
    --output-path "$OUTPUT.qza" \
    --input-format  ${LIB}EndFastqManifestPhred$PHRED
#WAS    --source-format ${LIB}EndFastqManifestPhred$PHRED

echo "Done"



