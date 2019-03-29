# NGS 16S Analysis of Mouse Gut Microbiota: Method and Supplementary Information
### Gut Microbes and Health ISP, Quadram Institute


This repository contains scripts and methods used for the analysis of 
**16S amplicons** analyzed to characterize the gut microbiota of 
mice to unravel the role of mucin-derived sialic acids.


## Scripts

The `scripts` directory contains the scripts used to produce results. 
To install Qiime 1.9 and/or Qiime 2.0 we used [Miniconda environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html): in particular [this instructions](https://hub.docker.com/search?q=qiime&type=image) for Qiime 1.9 and [this page](https://docs.qiime2.org/2019.1/install/native/) for Qiime 2x.

[Docker containers](https://hub.docker.com/search?q=qiime&type=image) are a viable alternative.


## Metadata

This is the samplesheet:

| SampleID | LinkerPrimerSequence  | Treatment | Reverseprimer       | Description |
| -------- | -------------------- | --------- | ------------------- | ----------- |
| S6262    | TCCTACGGGAGGCAGCAGT  | LowFat    | TCCTACGGGAGGCAGCAGT | Low62       |
| S6263    | TCCTACGGGAGGCAGCAGT  | LowFat    | TCCTACGGGAGGCAGCAGT | Low63       |
| S6264    | TCCTACGGGAGGCAGCAGT  | LowFat    | TCCTACGGGAGGCAGCAGT | Low64       |
| S6265    | TCCTACGGGAGGCAGCAGT  | LowFat    | TCCTACGGGAGGCAGCAGT | Low65       |
| S6266    | TCCTACGGGAGGCAGCAGT  | Control   | TCCTACGGGAGGCAGCAGT | Ctr66       |
| S6267    | TCCTACGGGAGGCAGCAGT  | Control   | TCCTACGGGAGGCAGCAGT | Ctr67       |
| S6268    | TCCTACGGGAGGCAGCAGT  | Control   | TCCTACGGGAGGCAGCAGT | Ctr68       |
| S6269    | TCCTACGGGAGGCAGCAGT  | HighFat   | TCCTACGGGAGGCAGCAGT | Hig69       |
| S6270    | TCCTACGGGAGGCAGCAGT  | HighFat   | TCCTACGGGAGGCAGCAGT | Hig70       |
| S6271    | TCCTACGGGAGGCAGCAGT  | HighFat   | TCCTACGGGAGGCAGCAGT | Hig71       |
| S6272    | TCCTACGGGAGGCAGCAGT  | HighFat   | TCCTACGGGAGGCAGCAGT | Hig72       |


## Methods

## Reference

Coletto E. _et al._, 2019
