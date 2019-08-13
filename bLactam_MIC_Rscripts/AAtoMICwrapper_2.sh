#!/bin/bash

x1="0"
if [ -d "$1" ]; then
if [ -s "$1""/Sample_PBP1A_AA.faa" ]; then
if [ -s "$1""/Sample_PBP2B_AA.faa" ]; then
if [ -s "$1""/Sample_PBP2X_AA.faa" ]; then
if [ -d "$2" ]; then
x1="1"
fi
fi
fi
fi
fi

if [ "$x1" == "1" ]; then
  AAseqDir=$1
  install_path=$2
  echo "Data folder is $AAseqDir"
  echo "Install path is $install_path"
else
  echo "usage bash ./AAtoMICwrapper.sh data_dir install_path"
  echo ""
  echo "install_path is a directory that contains the wrapper scripts/install"
  echo "data_dir is a directory that must conatin 3 files with the following exact names, respectively:"
  echo "Sample_PBP1A_AA.faa"
  echo "Sample_PBP2B_AA.faa"
  echo "Sample_PBP2X_AA.faa"
  echo ""
  echo "See README.txt for details"
  echo "Program not run"  
  exit 1
fi

#
faaDir=$AAseqDir"/Sample_AAtoMIC/faa/"
rm -rf   $faaDir
mkdir -p $faaDir
cd $faaDir

cp "${install_path}/bLactam_MIC_Rscripts/Ref_PBP_3.faa" .
cp $AAseqDir"/"*".faa" .

scr1="${install_path}/bLactam_MIC_Rscripts/Build_PBP_AA_tableR3.2.2.R"
Rscript $scr1 $faaDir

predir=$AAseqDir"/Sample_AAtoMIC/pre/"
rm -rf   $predir
mkdir -p $predir
cp ./Sample_PBP_AA_table.csv $predir

#dbdir="/scicomp/groups/OID/NCIRD/DBD/RDB/Strep_Lab/External/share/PBP_AA_to_MIC/currentDB"
#dbdir="/scicomp/groups/OID/NCIRD/DBD/RDB/Strep_Lab/External/share/PBP_AA_to_MIC/newDB"
#cp $dbdir"/"*  $predir

cd $predir

scr1="${install_path}/bLactam_MIC_Rscripts/AAtable_To_MIC_MM_RF_EN_2.R"
database="${install_path}/bLactam_MIC_Rscripts/newDB/"
Rscript $scr1 $predir $database

cp Sample_PBPtype_MIC2_Prediction.csv  $AAseqDir


echo "MIC pridiction results are in file:"
echo "$AAseqDir""/Sample_PBPtype_MIC2_Prediction.csv"



