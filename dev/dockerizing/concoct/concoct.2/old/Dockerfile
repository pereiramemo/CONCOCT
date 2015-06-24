
FROM debian:8

ENV PATH /bioinfo/software/anaconda/bin:$PATH

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

# Set up Anaconda environment for python2 and install install python dependencies
RUN cd /bioinfo/software; \
    wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.2.0-Linux-x86_64.sh;\
    chmod +x Anaconda-2.2.0-Linux-x86_64.sh;\
    ./Anaconda-2.2.0-Linux-x86_64.sh -p anaconda -b;\
    conda update --yes conda; \
    conda install --yes python=2.7; 
    

# Install concoct
RUN cd /bioinfo/software/; \
    conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam; \
    pip install bcbio-gff; \
    wget https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.3.1.tar.gz#md5=8786a194acf9673464c5455b11fd4332; \
    tar xzfv Sphinx-1.3.1.tar.gz; \
    cd 	Sphinx-1.3.1; \
    pip install -U sphinx;



	
RUN cd /bioinfo/software/; \ 
    wget --no-check-certificate https://github.com/BinPro/CONCOCT/archive/0.4.0.tar.gz;\
    tar xf 0.4.0.tar.gz; \
    cd /bioinfo/software/CONCOCT-0.4.0; \
    python setup.py install;


WORKDIR /workspace
    

###############################################################################
###############################################################################
###############################################################################



    
