# SPN-Resistance_sanger
A BUGSBio adaption of a sanger adaptation to the CDC AMR detection pipeline for pneumo

This is designed to be run using docker containers with AWS S3 for hosting data and results.

## To build
``` bash
docker build . -t spn-resistance:latest
```

## To run locally
``` bash
docker run \
  -v $HOME/.aws:/root/.aws                  \ # Make AWS credentials available
  -e FASTQ_BUCKET=s3://bucket-with-reads    \ # Where our previously obtained reads are
  -e FASTA_BUCKET=s3://bucket-with-assembly \ # Where our previously assembled contigs are
  spn-resistance:latest                     \ # The container we just built
  run.sh ACCESSION12345                       # The command and the accession number of the WGS data
```

## TODO upload the results to a bucket
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/SPN-Resistance_Sanger/blob/master/LICENSE)

