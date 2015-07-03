#!/bin/bash
HELPDOC=$( cat <<EOF
Maps given paired library to given reference with bowtie2 and uses picard to
remove duplicates. Requires enviornmental variable MRKDUP to be set and point
to the MarkDuplicates.jar file. Also requires bowtie2. For coverage calculation
BEDTools is required.

Usage:
    bash `basename $0` [options] <reads1> <reads2> <qname> <ref> <rname> <outdir>
Options:
    -t      Number of threads for bowtie2 and the java garbage collector
    -c      Calculate coverage with BEDTools
    -k      Keep all output from intermediate steps.
    -m      Mapping software: bbmap or bowtie2
    -h      This help documentation.
EOF
) 

set -o errexit
set -o nounset

# Default parameters
RMTMPFILES=true
CALCCOV=false
THREADS=1
BOWTIE2_OPT=''
MAPSOFT=bbmap

# Parse options
while getopts "m:khct:p:" opt; do
    case $opt in
        c)
            CALCCOV=true
            ;;
        k)
            RMTMPFILES=false
            ;;
        t)
            THREADS=$OPTARG
            ;;
        p)
            BOWTIE2_OPT=$OPTARG
            ;;
        m)  
            MAPSOFT=$OPTARG
            ;;
        h)
            echo "$HELPDOC"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "$HELPDOC"
            exit 1
            ;;
    esac
done
shift $(($OPTIND - 1)) 

##################################
# Checks START
##################################

# Check parameters
if [ "$#" -ne "6" ]
then
    echo "Invalid number of arguments: 6 needed but $# supplied" >&2
    echo "$HELPDOC"
    exit 1
fi

Q1=$1
if [ ! -f "$Q1" ]
then
    echo "Pair 1 doesn't exist: $1"
    exit 1
fi

Q2=$2
if [ ! -f "$Q2" ]
then
    echo "Pair 2 doesn't exist: $2"
    exit 1
fi

QNAME=$3
REF=$4
if [ ! -f "$REF" ]
then
    echo "Reference doesn't exist: $4"
    exit 1
fi
RNAME=$5
OUTDIR=${6%/}


##########################################
# Check sequence files 
##########################################

if [[ ! -s $Q1 || ! -s $Q2 ]]; then
    echo "$Q1 or $Q2 is empty" >&2
    exit 1
fi

##########################################
# Checks END
##########################################

mkdir -p $OUTDIR



MOUNT_POINT=/home/epereira/workspace/CONCOCT/dev/dockerizing/test2

drun_preprocess="sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/pre-process:v1"
drun_concoct="sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/concoct:v2"  
#the alias dosen't work from docker run, should be specified in the Dockerfile 

#drun_preprocess() { sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/pre-process:v1 $@;}
#drun_concoct() { sudo docker run --net=host --volume=$MOUNT_POINT/:/workspace epereira/concoct:v2 $@;}

##########################################
# Map sequence to assembly: START
##########################################

if [[ $MAPSOFT =~ [bB][bB]map ]]; then

	# Index reference
	if [[ ! -d ref ]]; then	
		#docker run
		$drun_preprocess bbmap.sh ref=$REF	 		
	fi

	# Align Paired end
	cat $Q1 $Q2 > tmp.fa; 
	#docker run
	$drun_preprocess bbmap.sh in=tmp.fa out=$OUTDIR/${RNAME}_${QNAME}.sam;
	rm tmp.fa; 

elif [[ $MAPSOFT =~ bowtie2 ]]; then

	# Index reference, Burrows-Wheeler Transform
    	if [ ! -e ${REF}.1.bt2 ]; then
		#docker run
    		$drun_preprocess bowtie2-build $REF $REF;
    	fi

	# Align Paired end
	#docker run
    	$drun_preprocess bowtie2 ${BOWTIE2_OPT} -p $THREADS -x $REF -1 $Q1 -2 $Q2 -S $OUTDIR/${RNAME}_${QNAME}.sam

else 

	echo "no mapping software provided"
	exit 1

fi

##########################################
# Map sequence to assembly: END
##########################################

#docker run
$drun_preprocess samtools faidx $REF
#docker run
$drun_preprocess samtools view -bt $REF.fai $OUTDIR/${RNAME}_${QNAME}.sam > $OUTDIR/${RNAME}_${QNAME}.bam
#docker run
$drun_preprocess samtools sort -m 10G -@ 5 $OUTDIR/${RNAME}_${QNAME}.bam $OUTDIR/${RNAME}_${QNAME}-s
#docker run
$drun_preprocess samtools index $OUTDIR/${RNAME}_${QNAME}-s.bam

# Mark duplicates and sort
#docker run
$drun_preprocess java -Xms1g -Xmx24g -XX:ParallelGCThreads=$THREADS -XX:MaxPermSize=1g -XX:+CMSClassUnloadingEnabled \
    -jar  /bioinfo/software/picard-tools-1.118/MarkDuplicates.jar \
    INPUT=$OUTDIR/${RNAME}_${QNAME}-s.bam \
    OUTPUT=$OUTDIR/${RNAME}_${QNAME}-smd.bam \
    METRICS_FILE=$OUTDIR/${RNAME}_${QNAME}-smd.metrics \
    AS=TRUE \
    VALIDATION_STRINGENCY=LENIENT \
    MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
    REMOVE_DUPLICATES=TRUE
#docker run
$drun_preprocess samtools sort -m 10G -@ 5 $OUTDIR/${RNAME}_${QNAME}-smd.bam $OUTDIR/${RNAME}_${QNAME}-smds

#docker run
$drun_preprocess samtools index $OUTDIR/${RNAME}_${QNAME}-smds.bam

# Determine Genome Coverage and mean coverage per contig
if $CALCCOV; then

    #docker run
    $drun_preprocess genomeCoverageBed -ibam $OUTDIR/${RNAME}_${QNAME}-smds.bam > $OUTDIR/${RNAME}_${QNAME}-smds.coverage
    
    awk 'BEGIN {pc=""} 
    {
        c=$1;
        if (c == pc) {
            cov=cov+$2*$5;
        } else {
            print pc,cov;
            cov=$2*$5;
        pc=c}
    } END {print pc,cov}' $OUTDIR/${RNAME}_${QNAME}-smds.coverage | tail -n +2 > $OUTDIR/${RNAME}_${QNAME}-smds.coverage.percontig
fi

# Remove temp files
if $RMTMPFILES; then
   sudo rm $OUTDIR/${RNAME}_${QNAME}.sam \
       $OUTDIR/${RNAME}_${QNAME}.bam \
       $OUTDIR/${RNAME}_${QNAME}-smd.bam \
       $OUTDIR/${RNAME}_${QNAME}-s.bam \
       $OUTDIR/${RNAME}_${QNAME}-s.bam.bai
fi
