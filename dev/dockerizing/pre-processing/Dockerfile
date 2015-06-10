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


ENV http_proxy="http://172.16.255.250:80"   
ENV https_proxy="http://172.16.255.250:80"

ENV PATH $PATH/:/bioinfo/software/bbmap/
ENV PATH $PATH/:/bioinfo/software/

RUN mkdir -p /bioinfo/software/

# Get basic debain packages needed
RUN apt-get update && apt-get install --yes  \ 
    build-essential \
    libgsl0-dev \
    git \
    zip \ 
    wget \
    python \
    python-pip \
    python-biopython
    

# Samtools 0.1.19
RUN apt-get install -qq samtools

# Bowtie2.1.0
RUN apt-get install -qq bowtie2

# BedTools
RUN apt-get install -qq bedtools

# BBmap
ENV PATH $PATH/:/bioinfo/software/bbmap/
RUN wget http://sourceforge.net/projects/bbmap/files/latest/download?source=typ_redirect -O bbmap.tar.gz
RUN tar xzfv bbmap.tar.gz -C /bioinfo/software/
RUN rm bbmap.tar.gz

# Install Java 7 to run bbmap
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections 
RUN echo yes | apt-get install --yes oracle-java7-installer

# Picard tools 1.118
# To get fuse to work, I need the following (Issue here: https://github.com/dotcloud/docker/issues/514,
# solution here: https://gist.github.com/henrik-muehe/6155333).
ENV MRKDUP /bioinfo/software/picard-tools-1.118/MarkDuplicates.jar
RUN apt-get install -qq libfuse2 openjdk-7-jre-headless
RUN cd /bioinfo/software; \
    wget "http://downloads.sourceforge.net/project/picard/picard-tools/1.118/picard-tools-1.118.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpicard%2Ffiles%2Fpicard-tools%2F1.118%2F&ts=1396879817&use_mirror=freefr" -O picard-tools-1.118.zip;\
    unzip picard-tools-1.118.zip

# CONCOCT scripts
RUN cd /bioinfo/software; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/dev/map-bowtie2-markduplicates2.sh; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/dev/cut_up_fasta.py; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/scripts/gen_input_table.py; \
wget --no-check-certificate https://raw.githubusercontent.com/pereiramemo/CONCOCT/master/scripts/map-bowtie2-markduplicates.sh

RUN chmod +x /bioinfo/software/cut_up_fasta.py
RUN chmod +x /bioinfo/software/map-bowtie2-markduplicates2.sh
RUN chmod +x /bioinfo/software/map-bowtie2-markduplicates.sh

WORKDIR workspace
