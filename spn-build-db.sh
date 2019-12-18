version="1.0.0"
url_base="https://github.com/sanger-pathogens/SPN-Resistance_Sanger/archive/"
outputdir="$(pwd)/spn-resistance-db-build-$(cat /proc/sys/kernel/random/uuid)"
destination=$(pwd)

trap "rm -rf ${outputdir}" EXIT
rm -rf "${outputdir}"
mkdir -p "${outputdir}"
cd "${outputdir}"
echo Downloading version "${version}"
wget -q "${url_base}/v${version}.tar.gz"
tar xf "v${version}.tar.gz"
cp -r SPN-Resistance_Sanger-${version}/SPN_Reference_DB ./SPN_Reference_DB-${version}
cd ./SPN_Reference_DB-${version}
for file in $(ls *.fasta)
do
  echo Processing "${file}" in $(pwd) with content $(ls)
  echo samtools faidx "${file}"
  echo bowtie2-build-s "./${file}" "${file}"
  samtools faidx "${file}"
  bowtie2-build-s "./${file}" "${file}"
done
for v in "1A" "2B" "2X"
do
   makeblastdb -in "SPN_bLactam_${v}-DB.faa" -dbtype prot -out "Blast_bLactam_${v}_prot_DB"
done
chmod 444 *
cd ..
cp -r "SPN_Reference_DB-${version}" "${destination}"
