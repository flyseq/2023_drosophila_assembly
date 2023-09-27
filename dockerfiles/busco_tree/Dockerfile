# Use NVIDIA image for GPU compatibility in ASTRAL, but...
# ASTRAL runs quickly enough to where we don't need it yet
#FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
FROM ubuntu:20.04

#install libs/dependencies
#manual install of Cmake for compatibility with Racon
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata \
 && apt-get install -y \
    bc \
    cmake \
    curl \
    default-jdk \
    default-jre \
    gcc \
    git \
    g++ \
    jq \
    make \
    parallel \
    pigz \
    phast \
    prank \
    python3 \
    python3-pip \
    wget \
    unzip \
    zip \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*
RUN mkdir /tools

# copy trimming script
COPY ./fasta_site_trim.py /tools

# install MAFFT 7.490
RUN wget https://mafft.cbrc.jp/alignment/software/\
mafft_7.490-1_amd64.deb \
 && dpkg -i mafft_7.490-1_amd64.deb \
 && apt install -f \
 && rm mafft_7.490-1_amd64.deb

# install BioPython
RUN pip install biopython

# Install ASTRAL-MP
RUN git clone --branch 'MP' https://github.com/smirarab/ASTRAL.git \
 && cd ASTRAL \
 && bash ./make.sh \
 && cp astral.*.jar /tools/astral.jar \
 && cp -r ./lib /tools \
 && cd / && rm -r ASTRAL

# Install IQtree
RUN wget https://github.com/iqtree/iqtree2/releases/download/v2.2.0.7/\
iqtree-2.2.0.7-Linux.tar.gz -O- | tar zxf - \
 && cp iqtree-2.2.0.7-Linux/bin/iqtree2 /usr/local/bin/iqtree \
 && rm -r iqtree-2.2.0.7-Linux

# install pal2nal
RUN wget http://www.bork.embl.de/pal2nal/distribution/pal2nal.v14.tar.gz \
 && tar zxf pal2nal.v14.tar.gz \
 && cp pal2nal.v14/pal2nal.pl /tools \
 && rm -r pal2nal.v14

# copy BUSCO GFF parse
COPY ./parsegff.sh /tools/
RUN chmod uga+x /tools/parsegff.sh

# install hyphy
RUN wget https://github.com/veg/hyphy/archive/refs/tags/2.5.42.tar.gz \
 && tar zxf 2.5.42.tar.gz \
 && rm 2.5.42.tar.gz \
 && cd hyphy-2.5.42 \
 && cmake . \
 && make -j MP \
 && make install
RUN rm -r hyphy-2.5.42

RUN git clone https://github.com/veg/hyphy-analyses.git

# install macse
#RUN wget https://bioweb.supagro.inra.fr/macse/releases/macse_v2.06.jar \
# && mv macse_v2.06.jar /tools/macse.jar
