#!/bin/bash

# This script is designed to be run as a part of a docker based workflow.
# It expects the following environment variables to be set:
#
#   FASTQ_BUCKET      The path to the S3 bucket containing the reads, eg. "s3://my-bucket/"
#   FASTA_BUCKET      The bucket containing the assemblies, eg. "s3://velvet-output/"
#   SPN_RES_BUCKET    The bucket where results from running this pipeline should be placed.
#
# The script takes a single argument which should be the accession number.
# 
# For a given argumment, eg. 'ACC12345', it is assumed there exists appropriate files on the
# buckets:
#
#   Reads:
#     FASTQ_BUCKET/ACC12345_1.fastq.gz
#     FASTQ_BUCKET/ACC12345_2.fastq.gz
#   Assembly:
#     FASTA_BUCKET/ACC12345.fasta



# Given an accession number, download the assembly and the reads and put them in the expected
# locations.

ACCESSION=$1

mkdir -p /work/velvet_assembly
mkdir -p /work/output

aws s3 cp "${FASTA_BUCKET}/${ACCESSION}.fasta"      /work/velvet_assembly/contigs.fa
aws s3 cp "${FASTQ_BUCKET}/${ACCESSION}_1.fastq.gz" /work/read_1.fastq.gz
aws s3 cp "${FASTQ_BUCKET}/${ACCESSION}_2.fastq.gz" /work/read_2.fastq.gz

zcat /work/read_1.fastq.gz > /work/read_1.fastq
zcat /work/read_2.fastq.gz > /work/read_2.fastq


# Note entirely sure what the intended use case is with regard to the final two parameters
# of typer.sh is.
# 
# We just use /work/output as the name of the directory to put results in...
mkdir /work/output


typer.sh /work/read_1.fastq /work/read_2.fastq /work/db/SPN_Reference_DB-1.0.0 batch /work/output
