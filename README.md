# TIPseqHunter
> Dockerfile for TIPseqHunter pipeline

### Motivation
[`TIPseqHunterPipelinejar.sh`](https://github.com/galantelab/TIPseqHunter/blob/master/TIPseqHunterPipelineJar.sh) and [`TipseqHunterPipelineJarSomatic.sh`](https://github.com/galantelab/TIPseqHunter/blob/master/TIPseqHunterPipelineJarSomatic.sh) need some java libraries as well as biological annotations and genome indexes. Therefor, manipulating all these dependencies ends up being troublesome. For that reason, [`docker`](https://www.docker.com/) is a good approach to overcome this kind of problem, because it has the ability to encapsulate the whole environment needed by the application, so that it can run in different machines. As result, the pipeline becomes more reliable and reproducible.

### Instalation
**TIPseqHunter** comes with all files required to build and run the pipeline on docker. The dependencies are splitted into tarballs: `TIPseqHunter_data.tar.gz.part*`. And the scripts are: [`tipseq_hunter_build.sh`](https://github.com/galantelab/TIPseqHunter/blob/master/tipseq_hunter_build.sh) and [`tipseq_hunter_run.sh`](https://github.com/galantelab/TIPseqHunter/blob/master/tipseq_hunter_run.sh).

* Firstly, you need to [`install docker`](https://docs.docker.com/install/);
* Clone this repository: `git clone https://github.com/galantelab/TIPseqHunter.git`;
* Run the builder script **tipseq_hunter_buiild.sh** inside the repository folder. One liner build: `cd TIPseqHunter/ && ./tipseq_hunter_build.sh`;

> Pay attention! You will need to use `sudo` in the commands if you are not member of the docker group

### Usage
Once installed the docker image, the user can utilize the script [`tipseq_hunter_run.sh`](https://github.com/galantelab/TIPseqHunter/blob/master/tipseq_hunter_run.sh) in order to automate the process of creating the container and running the pipeline. This script runs both **TIPseqHunterPipelineJar.sh** and **TIPseqHunterPipelineJarSomatic.sh** in sequence, so you need to call it just one time.

```
$ ./tipseq_hunter.sh -h
Usage ./tipseq_hunter_run.sh

./tipseq_hunter_run.sh [-i STR] -p PATH -f FILE -1 STR -2 STR -o PATH

Parameters:
  -h         Show this message
  -i         Docker image name. Default: 'tipseq_hunter'
  -p         Path for the fastq files (Note: this is the only path and file name is not included)
  -f         Read 1 file name of paired fastq files
  -1         Key word to recognize read 1 of fastq file
             Example: "_1" is the key word for CAGATC_1.fastq fastq file (Note: key has to be unique in the file name)
  -2         Key word to recognize read 2 of fastq file
             Example: "_2" is the key word for CAGATC_2.fastq fastq file) (Note: key has to be unique in the file name)
  -o         Path for the output files (Note: this is the only path and file name is not included)

```
### Example
```
$ tree
.
└── fastq
    ├── 108_M1_S12_L002_R1_001.fastq
    └── 108_M1_S12_L002_R2_001.fastq

```
Let's run our analisys for these files into fastq folder:
```
$ tipseq_hunter_run.sh \
  -p $(pwd)/fastq \
  -f 108_M1_S12_L002_R1_001.fastq \
  -1 R1 \
  -2 R2 \
  -o $(pwd)/results 2> results.log
```
> dirname, filename paths must be absolute, not relative

That is it! :smile:
