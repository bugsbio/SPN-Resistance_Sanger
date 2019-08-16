#!/bin/bash -l

temp_path=$(dirname $0)

## -- begin embedded SGE options --
read -a PARAM <<< $(/bin/sed -n ${LSB_JOBINDEX}p $1/job-control.txt)
## -- end embedded SGE options --

###This script is called for each job in the qsub array. The purpose of this code is to read in and parse a line of the job-control.txt file
###created by 'StrepLab-JanOw_GAS-wrapr.sh' and pass that information, as arguments, to other programs responsible for various parts of strain
###characterization (MLST, emm type and antibiotic drug resistance prediction).

readPair_1=${PARAM[0]}
readPair_2=${PARAM[1]}
allDB_dir=${PARAM[2]}
batch_out=${PARAM[3]}
sampl_out=${PARAM[4]}

###Start Doing Stuff###
cd "$sampl_out"
batch_name=$(echo "$sampl_out" | awk -F"/" '{print $(NF-2)}')
just_name=$(basename "$sampl_out")

### fastqc
echo Executing fastqc
fastqc_step.sh "${readPair_1}" "${readPair_2}" "${just_name}"

###Call GBS bLactam Resistances###
echo Executing:PBP-Gene_Typer.pl
PBP-Gene_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -r "$allDB_dir/MOD_bLactam_resistance.fasta" -n "$just_name" -s SPN -p 1A,2B,2X

###Predict bLactam MIC###
echo Executing PBP_AA_sampledir_to_MIC_20180710.sh
PBP_AA_sampledir_to_MIC_20180710.sh "$sampl_out" "$temp_path"

###Call GBS Misc. Resistances###
echo Executing SPN_Res_Typer.pl
SPN_Res_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -d "$allDB_dir" -r SPN_Res_Gene-DB_Final.fasta -n "$just_name"
echo Executing SPN_Target2MIC.pl 
SPN_Target2MIC.pl OUT_Res_Results.txt "$just_name"

echo Processing outputs

###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
tabl_out="TABLE_Isolate_Typing_results.txt"
printf "$just_name\t" >> "$tabl_out"

###PBP_ID Output###
justPBPs="NF"
sed 1d TEMP_pbpID_Results.txt | while read -r line
do
    if [[ -n "$line" ]]
    then
        justPBPs=$(echo "$line" | awk -F"\t" '{print $2}' | tr ':' '\t')
    fi
    printf "$justPBPs\t" >> "$tabl_out"
done

pbpID=$(tail -n1 "TEMP_pbpID_Results.txt" | awk -F"\t" '{print $2}')
if [[ ! "$pbpID" =~ .*NF.* ]] #&& [[ ! "$pbpID" =~ .*NEW.* ]]
then
    echo "No NF outputs for PBP Type"
    bLacTab=$(sed -e 's/\s\+$//g' -e 's/ /\t/g' BLACTAM_MIC_RF_with_SIR.txt | tail -n1 )
    printf "$bLacTab\t" >> "$tabl_out"
else
    echo "One of the PBP types has an NF"
    printf "NF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\t" >> "$tabl_out"
fi

###Resistance Targets###
while read -r line
do
    printf "$line\t" | tr ',' '\t' >> "$tabl_out"
done < RES-MIC_"$just_name"

if [[ -e $(echo ./velvet_output/*_Logfile.txt) ]]
then
    vel_metrics=$(echo ./velvet_output/*_Logfile.txt)
    echo "velvet metrics file: $vel_metrics";
    velvetMetrics.pl -i "$vel_metrics";
    line=$(cat velvet_qual_metrics.txt | tr ',' '\t')
    printf "$line\t" >> "$tabl_out"

    printf "$readPair_1\t" >> "$tabl_out";
    pwd | xargs -I{} echo {}"/velvet_output/contigs.fa" >> "$tabl_out"
else
    printf "NA\tNA\tNA\tNA\t$readPair_1\tNA\n" >> "$tabl_out"
fi


###Remove Temporary Files###
#rm cutadapt*.fastq
#rm *.pileup
#rm *.bam
#rm *.sam
#rm TEMP*

