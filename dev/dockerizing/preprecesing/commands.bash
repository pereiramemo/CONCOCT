##############################################################################################
##############################################################################################
##############################################################################################
# CONCOCT preprocessing commands
##############################################################################################
##############################################################################################
##############################################################################################



# cut up contigs larger than 10k
 python $CONCOCT/scripts/cut_up_fasta.py -c 10000 -o 0 -m contigs/velvet_71.fa > ../CONCOCT-complete-example/contigs/velvet_71_c10K.fa
 
# build index for bowtie2
bowtie2-build contigs/velvet_71_c10K.fa contigs/velvet_71_c10K.fa

# cut up fasta
# within docker
cut_up_fasta.py -c 10000 -o 0 -m contigs/velvet_71.fa > contigs/velvet_71_c10K.tmp1.fa

#from script
docker run -tiv $(pwd)/velvet_71.fa:/workspace/velvet_71.fa test2 /bin/bash -c "cut_up_fasta.py -c 10000 -o 0 -m velvet_71.fa" > velvet_71_c10K.tmp1.fa 

# map reads 
# within docker: docker run -tiv $(pwd)/:/workspace/ test2 bash
for f in reads/*_R1.fa; do
    mkdir -p map.tmp1/$(basename $f);
    cd map.tmp1/$(basename $f);
    bash map-bowtie2-markduplicates.sh -ct 1 -p '-f' ../../$f  ../../$(echo $f | sed s/R1/R2/) pair ../../velvet_71_c10K.fa asm bowtie2;
    cd ../..;
done



for f in $CONCOCT_TEST/reads/*_R1.fa; do
    mkdir -p map/$(basename $f);
    cd map/$(basename $f);
    bash $CONCOCT/scripts/map-bowtie2-markduplicates.sh -ct 1 -p '-f' $f $(echo $f | sed s/R1/R2/) pair $CONCOCT_EXAMPLE/contigs/velvet_71_c10K.fa asm bowtie2;
    cd ../..;
done


