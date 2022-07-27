conda activate enviroDNA


projectname="trnl"
scriptDir="/share/ScratchGeneral/nenbar/projects/Anthony/scripts/$projectname"
projectDir=$scriptDir
inDirs="/share/ScratchGeneral/nenbar/projects/Anthony/scripts/$projectname/split"
resultsDir="/share/ScratchGeneral/nenbar/projects/Anthony/results"
mkdir -p $resultsDir
mkdir -p $inDirs
mkdir -p $projectDir/seqs
dbDir="$projectDir/db"


###### data downloaded from NCBI, 3480122 records

#perl -pe 'print $_;$i=0;while(<>){$i++;if($_=~m/>/){s/\n/.$i\n/;};print $_}' <$dbDir/COI_metazoa.fasta >CO-ARBitrator_joint_uniq.fasta

#split fasta files with pyfasta
cat ncbi/*.fasta > $dbDir/trnl_all.fasta
pyfasta split -n 10 $dbDir/trnl_all.fasta


mv $dbDir/*0*.fasta $inDirs


for file in `ls $inDirs/*.fasta`;do
  echo $file
  pyfasta split -n 20 $file
done;

mv $inDirs/trnl_all.0{0..9}.fasta $projectDir/seqs

for file in `ls $inDirs/*.fasta | grep -P "\\d.fasta"`;do
  sampleName=`basename $file | sed 's/.fasta//'`
  mkdir -p $inDirs/$sampleName
  mv -f $file $inDirs/$sampleName
done

rm $inDirs/*fasta* 



cutoff=10

for inDir in `ls $inDirs`;do
  sampleName=`echo $inDir | sed 's/\///'`
  echo $sampleName
  hammingLine="python $scriptDir/hammingdapt4.py --input_dir $inDirs/$sampleName -f CGAAATCGGTAGACGCTACG -r CCATTGAGTCTCTGCACCTATC --min_length=50 --max_length=500 --distance_limit=$cutoff"
  qsub -b y -cwd -j y -N hd -R y -pe smp 2 -V $hammingLine
done

for file in `ls $inDirs/**/*.trimmed.fasta`;do
  sampleName=`echo $file | sed 's/.trimmed.fasta/.coi.fasta/'`
  echo $sampleName
  mv -f $file $sampleName
done

rm $scriptDir/split/**/*trimmed*
mkdir coi.$cutoff
mv -f $scriptDir/split/**/*coi* coi.$cutoff
cat $scriptDir/coi.$cutoff/* >coi.$cutoff.fasta
