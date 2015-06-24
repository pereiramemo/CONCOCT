FROM debian:8

ENV PATH /bioinfo/software/miniconda/bin:$PATH

ENV http_proxy="http://172.16.255.250:80"   
ENV https_proxy="http://172.16.255.250:80"

# Get basic packages needed
RUN apt-get update && apt-get install -y \ 
wget \
build-essential \
libgsl0-dev \
git \
zip \ 
unzip


RUN mkdir -p /bioinfo/software/

# Set up Miniconda environment for python2
RUN cd /bioinifo/software;\
    wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh -O miniconda.sh;\
    chmod +x miniconda.sh;\
    ./miniconda.sh -p /bioinfo/software/miniconda -b;\
    conda update --yes conda;
    

# Fix pycosat 

RUN apt-get install -y python-dev python-pip;

RUN pip install pycosat;

RUN conda update --yes conda; \
    conda remove --features debug; 
    
RUN conda install --yes python=2.7
    
    
# Install python dependencies and fetch and install CONCOCT 0.4.0
RUN cd /bioinfo/software/;\
    conda update --yes conda;\
    conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam;\
    pip install bcbio-gff;\
    wget --no-check-certificate https://github.com/BinPro/CONCOCT/archive/0.4.0.tar.gz;\
    tar xf 0.4.0.tar.gz;\
    cd CONCOCT-0.4.0;\
    python setup.py install


WORKDIR /workspace
    
    
