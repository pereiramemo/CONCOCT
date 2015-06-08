# Docker: preprocessing data for CONCOCT v0.4.0 (running map-bowtie2-markduplicates2.sh) (http://github.com/BinPro/CONCOCT) 
# 1) Cutting up contigs
# 2) Map the Reads onto the Contigs 
# 3) Generate coverage table
# 4) Generate linkage table
#
# VERSION 0.4.0
# 
# This docker creates and sets up an Bebian environment with all
#    software to generate the abundace table input for CONCOCT.
#
# To login to the docker with a shared directory from the host do:
#
# sudo docker run -v /my/host/shared/directory:/my/docker/location -i -t binnisb/concoct_0.4.0 /bin/bash
#

FROM debian:8

ENV PATH $PATH/:/bioinfo/software/bbmap/
ENV PATH $PATH/:/bioinfo/software/miniconda/bin 
ENV PATH $PATH/:/bioinfo/software/
ENV PATH /opt/miniconda/bin:$PATH


RUN mkdir -p /bioinfo/software/

# Get basic debain packages needed
RUN apt-get update && apt-get install -y \ 
    build-essential \
    libgsl0-dev \
    git \
    zip \ 
    wget 

# Set up Miniconda environment for python2
#RUN cd /bioinfo/software/; \
#    wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh -O miniconda.sh; 

#RUN chmod +x /bioinfo/software/miniconda.sh 
    
#RUN /bioinfo/software/miniconda.sh -p /bioinfo/software/miniconda -b; 

#RUN conda update --yes conda; \
#    conda install --yes python=2.7; \
#    conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam; \
#    pip install bcbio-gff; \
#    python setup.py install
    
RUN cd /opt;\
    wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh -O miniconda.sh;\
    chmod +x miniconda.sh;\
    ./miniconda.sh -p /opt/miniconda -b;\
    conda update --yes conda;\
    conda install --yes python=2.7    

RUN cd /opt;\
    conda update --yes conda;\
    conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam;\
    pip install bcbio-gff;\
    wget --no-check-certificate https://github.com/BinPro/CONCOCT/archive/0.4.0.tar.gz;\
    tar xf 0.4.0.tar.gz;\
    cd CONCOCT-0.4.0;\
    python setup.py install
    
    

# Samtools 0.1.19
RUN apt-get install -qq samtools

# Bowtie2.1.0
RUN apt-get install -qq bowtie2

# BedTools
RUN apt-get install -qq bedtools

# BBmap
ENV PATH $PATH/:/bioinfo/software/bbmap/
RUN  wget http://sourceforge.net/projects/bbmap/files/latest/download?source=typ_redirect -O bbmap.tar.gz
RUN tar xzfv bbmap.tar.gz -C /bioinfo/software/
RUN rm bbmap.tar.gz

# Install Java 7 to run bbmap
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN apt-get install oracle-java7-installer

# CONCOCT scripts
RUN cd /bioinfo/software; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/dev/map-bowtie2-markduplicates2.sh; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/dev/cut_up_fasta.py





