# BIOINFORMATICS: GENOME SEARCH - Sara Bennett and Jonathan Gilman
#usage: bash genomeSearch.sh

#create file with all of the reference sequences for each gene
cat ref_sequences/hsp70gene_*.fasta > hsp70
cat ref_sequences/mcrAgene_*.fasta > mcrA

#align the reference sequences in muscle
../../tools/muscle -in hsp70 -out hsp70align
../../tools/muscle -in mcrA -out mcrAalign

#use hmmbuild to create HMM profile for hsp70 and mcrA
../../tools/hmmbuild hsp70build hsp70align
../../tools/hmmbuild mcrAbuild mcrAalign

#use hmmsearch to search for matches of hsp70 and mcrA in the proteome from the HMM profiles from hmmbuild
cd proteomes
for file in *.fasta
do
../../../tools/hmmsearch --tblout hsp70_$file ../hsp70build $file
../../../tools/hmmsearch --tblout mcrA_$file ../mcrAbuild $file
done

#cut matches for hsp70 and mcrA from the search files and combine into a clean table output text file
#Column1 - filename, column 2 - hsp70 matches, column 3 - mcrA matches)
for file in proteome_*.fasta
do
hsp0match=$(cat hsp70_$file | grep -v '#' | wc -l)
mcrAmatch=$(cat mcrA_$file | grep -v '#' | wc -l)
echo "$file, $hsp0match, $mcrAmatch " | sed 's/.fasta//g' >> ../matches.txt
done

cd ../
#filter out proteomes that have at least 1 hsp70 and at least 1 mcrA (delete all proteomes with 0 values)
cat matches.txt | grep -v " 0" | sort -k 2nr | cut -d "," -f 1  > recommended.txt

#matches.txt shows all of the hsp70 mcrA matches for each proteome
#recommended.txt shows the proteomes in order from most resistant (most copies of hsp70) to least resistant, of the proteomes with a copy of each HSP70 and McrA
