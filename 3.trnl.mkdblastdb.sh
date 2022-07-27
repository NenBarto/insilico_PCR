conda activate enviroDNA


export BLASTDB_LMDB_MAP_SIZE=100000000
inFa="/share/ScratchGeneral/nenbar/projects/Anthony/annotation/blast/trnl/trnl_plants.fasta.gz"
inTax="/share/ScratchGeneral/nenbar/projects/Anthony/annotation/blast/trnl/taxdb.btd"
out="/share/ScratchGeneral/nenbar/projects/Anthony/annotation/blast/trnl/trnl_plants"
commandLine="gunzip -c $inFa | makeblastdb -in - -parse_seqids -blastdb_version 5 -taxid_map $inTax -title trnl_plants_070221 -dbtype nucl -out $out"
qsub -b y -cwd -j y -N blast -R y -pe smp 20 -V $commandLine


