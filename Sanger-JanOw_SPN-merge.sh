#!/usr/bin/env bash


out_jobCntrl=$1
out_analysis=$2

###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
batch_name=$(head -n1 $out_jobCntrl/job-control.txt | awk -F" " '{print $5}' | awk -F"/" '{print $(NF-2)}')
#printf "Sample\tSerotype\tST\taroe\tgdh_\tgki_\trecP\tspi_\txpt_\tddl_\tPBP_Code(1A:2B:2X)\tMisc_Resistance\tGen_Resistance\tPlasmid_Target\n" >> "$out_analysis"/TABLE_SPN_"$batch_name"_Typing_Results.txt
printf "Sample\tPBP1A\tPBP2B\tPBP2X\tWGS_PEN_SIGN\tWGS_PEN\tWGS_PEN_SIR_Meningitis\tWGS_PEN_SIR_Nonmeningitis\tWGS_AMO_SIGN\tWGS_AMO\tWGS_AMO_SIR\tWGS_MER_SIGN\tWGS_MER\tWGS_MER_SIR\tWGS_TAX_SIGN\tWGS_TAX\tWGS_TAX_SIR_Meningitis\tWGS_TAX_SIR_Nonmeningitis\tWGS_CFT_SIGN\tWGS_CFT\tWGS_CFT_SIR_Meningitis\tWGS_CFT_SIR_Nonmeningitis\tWGS_CFX_SIGN\tWGS_CFX\tWGS_CFX_SIR\tWGS_AMP_SIGN\tWGS_AMP\tWGS_AMP_SIR\tWGS_CPT_SIGN\tWGS_CPT\tWGS_CPT_SIR\tWGS_ZOX_SIGN\tWGS_ZOX\tWGS_ZOX_SIR\tWGS_FOX_SIGN\tWGS_FOX\tWGS_FOX_SIR\tEC\tWGS_ERY_SIGN\tWGS_ERY\tWGS_ERY_SIR\tWGS_CLI_SIGN\tWGS_CLI\tWGS_CLI_SIR\tWGS_SYN_SIGN\tWGS_SYN\tWGS_SYN_SIR\tWGS_LZO_SIGN\tWGS_LZO\tWGS_LZO_SIR\tWGS_ERY/CLI\tCot\tWGS_COT_SIGN\tWGS_COT\tWGS_COT_SIR\tTet\tWGS_TET_SIGN\tWGS_TET\tWGS_TET_SIR\tWGS_DOX_SIGN\tWGS_DOX\tWGS_DOX_SIR\tFQ\tWGS_CIP_SIGN\tWGS_CIP\tWGS_CIP_SIR\tWGS_LFX_SIGN\tWGS_LFX\tWGS_LFX_SIR\tOther\tWGS_CHL_SIGN\tWGS_CHL\tWGS_CHL_SIR\tWGS_RIF_SIGN\tWGS_RIF\tWGS_RIF_SIR\tWGS_VAN_SIGN\tWGS_VAN\tWGS_VAN_SIR\tWGS_DAP_SIGN\tWGS_DAP\tWGS_DAP_SIR\tContig_Num\tN50\tLongest_Contig\tTotal_Bases\tReadPair_1\tContig_Path\n" >> "$out_analysis"/TABLE_SPN_"$batch_name"_Typing_Results.txt
while read -r line
do
    batch_name=$(echo $line | awk -F" " '{print $5}' | awk -F"/" '{print $(NF-2)}')
    final_outDir=$(echo $line | awk -F" " '{print $5}')
    final_result_Dir=$(echo $line | awk -F" " '{print $4}')
    #cat $final_outDir/SAMPLE_Isolate__Typing_Results.txt >> $final_result_Dir/SAMPL_SPN_"$batch_name"_Typing_Results.txt
    cat $final_outDir/TABLE_Isolate_Typing_results.txt >> $final_result_Dir/TABLE_SPN_"$batch_name"_Typing_Results.txt
    if [[ -e $final_outDir/TEMP_newPBP_allele_info.txt ]]
    then
	cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_SPN_"$batch_name"_Typing_Results.txt
    fi
done < $out_jobCntrl/job-control.txt
