# Qiime 1.9 analysis

Place your uncompresed FASTQ reads in a directory and run
```
path/to/qiime1_closedref.pl -i reads -o qiime1_closedref -m mapping_file.tsv
```
Where:
 - `-i` the input directory containing the FASTQ reads (uncompressed)
 - `-m` the metadata file (mapping file) in TSV format
 - `-o` the desired output directory name
