#!/usr/bin/env bash

read_pair_1=${1}
read_pair_2=${2}
sample_name=${3}

fastq1_trimd="./cutadapt_${sample_name}_S1_L001_R1_001.fastq"
fastq2_trimd="./cutadapt_${sample_name}_S1_L001_R2_001.fastq"
temp1="./temp1.fastq"
temp2="./temp2.fastq"
cutadapt -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -q 20 --minimum-length 50 --paired-output "${temp2}" -o "${temp1}" "${read_pair_1}" "${read_pair_2}"
cutadapt -b AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -q 20 --minimum-length 50 --paired-output "${fastq1_trimd}" -o "${fastq2_trimd}" "${temp2}" "${temp1}"
rm "${temp1}" "${temp2}"

###Run fastqc on Processed Reads
outdir1="./${sample_name}_R1_cut"
outdir2="./${sample_name}_R2_cut"
mkdir -p "${outdir1}" "${outdir2}"
fastqc "${fastq1_trimd}" --outdir="${outdir1}"
fastqc "${fastq2_trimd}" --outdir="${outdir2}"