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
