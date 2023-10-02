FROM nvidia/cuda:11.2.1-cudnn8-devel-ubuntu20.04

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bc \
    bedtools \
    bwa \
    bzip2 \
    cmake \
    curl \
    default-jdk \
    default-jre \
    gcc \
    git \
    g++ \
    libboost-all-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libhdf5-dev \
    liblzma-dev \
    libncurses5-dev \
    libssl-dev \
    libzmq5 \
    miniasm \
    parallel \
    pigz \
    python3.8 \
    python3.8-venv \
    python3-pip \
    python-is-python3 \
    racon \
    wget \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

#install Guppy
RUN wget -q https://mirror.oxfordnanoportal.com/software/analysis/ont_guppy_6.5.7-1~focal_amd64.deb \
 && dpkg -i --ignore-depends=libcuda1 ont_guppy_6.5.7-1~focal_amd64.deb
RUN rm ont_guppy_6.5.7-1~focal_amd64.deb

# install flye
RUN git clone --branch "2.9.2" https://github.com/fenderglass/Flye.git \
 && cd Flye \
 && python3 setup.py install
RUN rm -r Flye

# install minimap2
RUN git clone --branch "v2.26" https://github.com/lh3/minimap2.git \
 && cd minimap2 \
 && make -j \
 && mv minimap2 /usr/local/bin/
RUN rm -r minimap2

# install medaka
ENV TF_FORCE_GPU_ALLOW_GROWTH=true
ENV SINGULARITYENV_LC_ALL="C"

RUN wget -q https://github.com/git-lfs/git-lfs/releases/download/\
v3.2.0/git-lfs-linux-amd64-v3.2.0.tar.gz \
 && tar -zxf git-lfs-linux-amd64-v3.2.0.tar.gz \
 && cd git-lfs-3.2.0 \
 && ./install.sh \
 && git lfs install
RUN rm -r git-lfs*

RUN git clone --recursive https://github.com/nanoporetech/medaka.git \
 && cd medaka \
 && pip3 install -r requirements.txt \
 && make -j install \
 && python3 setup.py install

#install samtools, etc.
RUN wget -q https://github.com/samtools/samtools/releases/download/\
1.18/samtools-1.18.tar.bz2 \
 && tar -xjf samtools-1.18.tar.bz2 \
 && cd /samtools-1.18 \
 && ./configure \
 && make -j \
 && make install
RUN rm -r samtools-1.18*

RUN wget -q https://github.com/samtools/htslib/releases/download/\
1.18/htslib-1.18.tar.bz2 \
 && tar -xjf htslib-1.18.tar.bz2 \
 && cd /htslib-1.18 \
 && ./configure \
 && make -j \
 && make install
RUN rm -r htslib-1.18*

RUN wget -q https://github.com/samtools/bcftools/releases/download/\
1.18/bcftools-1.18.tar.bz2 \
 && tar -xjf bcftools-1.18.tar.bz2 \
 && cd /bcftools-1.18 \
 && ./configure \
 && make -j \
 && make install
RUN rm -r bcftools-1.18*

# install purge_dups
RUN git clone https://github.com/dfguan/purge_dups.git \
 && cd purge_dups/src \
 && make -j \
 && for i in $(find . -executable -type f); do mv $i /usr/local/bin/; done
RUN rm -r purge_dups

# download pilon
RUN mkdir /tools
RUN wget -q https://github.com/broadinstitute/pilon/releases/\
download/v1.23/pilon-1.23.jar \
 && mv pilon-1.23.jar /tools/pilon.jar

# install sambamba
RUN wget -q https://github.com/biod/sambamba/releases/download/v0.8.2/\
sambamba-0.8.2-linux-amd64-static.gz \
  && gunzip sambamba-0.8.2-linux-amd64-static.gz \
  && chmod +x sambamba-0.8.2-linux-amd64-static \
  && mv sambamba-0.8.2-linux-amd64-static /usr/local/bin/sambamba

#install BBMap + tools
RUN wget -q https://downloads.sourceforge.net/project/bbmap/\
BBMap_38.96.tar.gz \
 && tar zxf BBMap_38.96.tar.gz -C /tools \
 && rm BBMap_38.96.tar.gz

# install pomoxis
RUN pip3 install git+https://github.com/artic-network/porechop \
 && pip3 install git+https://github.com/nanoporetech/pomoxis.git

# install seqkit
RUN wget -q https://github.com/shenwei356/seqkit/releases/\
download/v2.3.1/seqkit_linux_amd64.tar.gz \
 && tar zxf seqkit_linux_amd64.tar.gz \
 && chmod uga+x seqkit \
 && mv seqkit /usr/local/bin \
 && rm seqkit_linux_amd64.tar.gz

# install Dorado
RUN cd /tools \
 && wget -q https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.3.4-linux-x64.tar.gz \
 && tar zxf dorado-0.3.4-linux-x64.tar.gz \
 && rm dorado-0.3.4-linux-x64.tar.gz \
 && ln -sf /tools/dorado-0.3.4-linux-x64/bin/dorado /usr/local/bin/

ENV LANG="C"
ENV LC_ALL="C"
ENV SINGULARITYENV_LANG="C"
ENV SINGULARITYENV_LC_ALL="C"

# install guppy duplex
RUN pip install ont-guppy-duplex-pipeline

# install ratatosk
RUN cd /tools \
 && git clone --recursive https://github.com/DecodeGenetics/Ratatosk.git \
 && cd Ratatosk \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make -j \
 && make install \
 && rm -r /tools/Ratatosk

# install meryl
RUN cd /tools \
 && wget -q https://github.com/marbl/meryl/releases/download/v1.4/meryl-1.4.Linux-amd64.tar.xz \
 && tar xJf meryl-1.4.Linux-amd64.tar.xz \
 && rm meryl-1.4.Linux-amd64.tar.xz \
 && ln -s /tools/meryl-1.4/bin/* /usr/local/bin

# install merqury
RUN cd /tools \
 && wget -q https://github.com/marbl/merqury/archive/v1.3.tar.gz \
 && tar zxf v1.3.tar.gz \
 && rm -r v1.3.tar.gz \
 && ln -s /tools/merqury-1.3/merqury.sh /usr/local/bin/merqury \
 && ln -s /tools/merqury-1.3/best_k.sh /usr/local/bin/best-k.sh

ENV MERQURY="/tools/merqury-1.3"

# install yak
RUN cd /tools \
 && git clone https://github.com/lh3/yak \
 && cd yak \
 && make -j \
 && ln -s /tools/yak/yak /usr/local/bin/yak
