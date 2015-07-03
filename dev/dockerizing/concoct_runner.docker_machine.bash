#!/bin/bash

HELPDOC=$( cat <<EOF
This script creates runs concoct and carries out all the pre precessing steps:
cutting contigs, mapping reads anb generating the coverage tables.
EOF
)

echo $HELPDOC


#######################################################################################
#######################################################################################
# docker functions
#######################################################################################
#######################################################################################

MOUNT_POINT=$1

if [ ! $MOUNT_POINT ]; then

        echo "please provide the path for mounting";
        exit 1;
fi


#drun_preprocess() { sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/pre-process:v1 $@;}
#drun_concoct() { sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/concoct:v2

drun_preprocess="docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/pre-process:v1 /bin/bash -c"
drun_concoct="docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/concoct:v2"

#######################################################################################
#######################################################################################
# # Pull image
#######################################################################################
#######################################################################################

docker pull epereira/pre-process:v1
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: epereira/pre-process:v1 not found" ;
  echo $ERROR_MESSAGE
  exit 1
fi

docker pull epereira/concoct:v2
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: epereira/concoct:v2 not found" ;
  echo $ERROR_MESSAGE
  exit 1
fi

#######################################################################################
#######################################################################################
# Check if programs are installed
#######################################################################################
#######################################################################################

$drun_preprocess "bowtie2 --help"
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: program bowtie2" ;
  echo $ERROR_MESSAGE
  exit 1
fi

$drun_preprocess  "bbmap.sh --help"
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: program bbmap.sh" ;
  echo $ERROR_MESSAGE
  exit 1
fi

$drun_preprocess "if [ -x /usr/bin/samtools ]; then echo samtools checked; fi"
 if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: program samtools" ;
  echo $ERROR_MESSAGE
  exit 1
fi

MRKDUP="/bioinfo/software/picard-tools-1.118/MarkDuplicates.jar"
$drun_preprocess "if [ -x $MRKDUP ]; then echo MarkDuplicate.jar checked; fi"
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: program genomeCoverageBed" ;
  echo $ERROR_MESSAGE
  exit 1
fi

$drun_concoct concoct --help
if [ "$?" -ne "0" ]; then
  ERROR_MESSAGE="failed: program concoct" ;
  echo $ERROR_MESSAGE
  exit 1
fi

#######################################################################################
#######################################################################################
# Cut up contigs
#######################################################################################
#######################################################################################

$drun_preprocess "cut_up_fasta.py -c 10000 -o 0 -m contigs/velvet_71.fa > contigs/velvet_71_c10K.fa"

#######################################################################################
#######################################################################################
# Map reads onto the contigs
#######################################################################################
#######################################################################################


for f in reads/*_R1.fa; do
    mkdir -p map/$(basename $f);
    bash $MOUNT_POINT/scripts/map-bowtie2-markduplicates3.docker_machine.sh -m bbmap -ct 1 -p '-f' $f $(echo $f | sed s/R1/R2/) pair contigs/velvet_71_c10K.fa asm map/$(basename $f)/bbmap $MOUNT_POINT;
done

#######################################################################################
#######################################################################################
# Generate Coverage Table
#######################################################################################
#######################################################################################

$drun_preprocess "gen_input_table.py --isbedfiles  --samplenames <(ls -d  map/Sample* | sed 's/.*\///' | cut -d"_" -f1) contigs/velvet_71_c10K.fa  map/*/bbmap/asm_pair-smds.coverage" > concoct_inputtable.tsv

#######################################################################################
#######################################################################################
# Run concoct
#######################################################################################
#######################################################################################

$drun_concoct concoct -c 40 --coverage_file concoct_inputtable.tsv --composition_file contigs/velvet_71_c10K.fa -b out


