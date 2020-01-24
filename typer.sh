#!/usr/bin/env bash

readPair_1=${1}
readPair_2=${2}
allDB_dir=${3}
batch_out=${4}
sampl_out=${5}

temp_path=$(dirname $0)

echoerr() { printf "%s\n" "$*" >&2; }

###Start Doing Stuff###lo
cd "$sampl_out"
batch_name=$(echo "$sampl_out" | awk -F"/" '{print $(NF-2)}')
just_name=$(basename "$sampl_out")

###Call GBS bLactam Resistances###
echoerr Executing:PBP-Gene_Typer.pl
PBP-Gene_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -r "$allDB_dir/MOD_bLactam_resistance.fasta" -n "$just_name" -s SPN -p 1A,2B,2X

###Predict bLactam MIC###
echoerr Executing PBP_AA_sampledir_to_MIC_20180710.sh
PBP_AA_sampledir_to_MIC_20180710.sh "$sampl_out" "$temp_path"

###Call GBS Misc. Resistances###
echoerr Executing SPN_Res_Typer.pl
SPN_Res_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -d "$allDB_dir" -r SPN_Res_Gene-DB_Final.fasta -n "$just_name"
echoerr Executing SPN_Target2MIC.pl
SPN_Target2MIC.pl OUT_Res_Results.txt "$just_name"

echoerr Processing outputs

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
    echoerr "No NF outputs for PBP Type"
    bLacTab=$(sed -e 's/\s\+$//g' -e 's/ /\t/g' BLACTAM_MIC_RF_with_SIR.txt | tail -n1 )
    printf "$bLacTab\t" >> "$tabl_out"
else
    echoerr "One of the PBP types has an NF"
    for i in {1..33}; do
      printf "NF\t" >> "$tabl_out"
    done
fi

###Resistance Targets###
while read -r line
do
    printf "$line\n" | tr ',' '\t' >> "$tabl_out"
done < RES-MIC_"$just_name"
