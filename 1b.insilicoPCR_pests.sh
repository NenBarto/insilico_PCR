conda activate enviroDNA


projectname="COI"
scriptDir="/share/ScratchGeneral/nenbar/projects/Anthony/scripts/$projectname"
projectDir=$scriptDir
inDirs="/share/ScratchGeneral/nenbar/projects/Anthony/scripts/$projectname/split"
resultsDir="/share/ScratchGeneral/nenbar/projects/Anthony/results"
mkdir -p $resultsDir
mkdir -p $inDirs

dbDir="$projectDir/db/pests"


###### data downloaded from NCBI, 3480122 records

perl -pe 'print $_;$i=0;while(<>){$i++;if($_=~m/>/){s/\n/.$i\n/;};print $_}' <$dbDir/pests.fasta >pests_uniq.fasta

#split fasta files with pyfasta
pyfasta split -n 10 $dbDir/pests_uniq.fasta

mv $dbDir/*0*.fasta $inDirs

for file in `ls $inDirs/*.fasta | grep -P "\\d.fasta"`;do
  sampleName=`basename $file | sed 's/.fasta//'`
  mkdir -p $inDirs/$sampleName
  mv -f $file $inDirs/$sampleName
done

rm $inDirs/*fasta* 



cutoff=19

for inDir in `ls $inDirs`;do
  sampleName=`echo $inDir | sed 's/\///'`
  echo $sampleName
  hammingLine="python $scriptDir/hammingdapt4.py --input_dir $inDirs/$sampleName -f GGWACWGGWTGAACWGTWTAYCCYCC -r TAIACYTCIGGRTGICCRAARAAYCA --min_length=60 --max_length=1000 --distance_limit=$cutoff"
  qsub -b y -cwd -j y -N hd -R y -pe smp 2 -V $hammingLine
done

for file in `ls $inDirs/**/*.trimmed.fasta`;do
  sampleName=`echo $file | sed 's/.trimmed.fasta/.pests.fasta/'`
  echo $sampleName
  mv -f $file $sampleName
done

rm $scriptDir/split/**/*trimmed*
mkdir pests.$cutoff
mv -f $scriptDir/split/**/*pests.fasta pests.$cutoff
cat $scriptDir/pests.$cutoff/* >pests.$cutoff.fasta
