FROM ubuntu:18.04
MAINTAINER = path-help@sanger.ac.uk

ARG DEBIAN_FRONTEND=noninteractive

ARG CRAN_URL="https://cran.ma.imperial.ac.uk"

RUN apt-get update -y -qq \
      && apt-get install -y -qq apt-transport-https software-properties-common \
      && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
      && apt-get update -y -qq\
      && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
      && apt-get install -y -qq \
        locales \
        wget \
        unzip \
        r-base \
        gcc \
        build-essential \
        libx11-dev \
        bzip2 \
        git \
        perl \
        ncbi-blast+ \
        bedtools \
        clustalo \
        prodigal \
        srst2 \
        emboss \
        tabix \
        python-pip \
        vcftools \
        libbz2-dev \
        liblzma-dev \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && pip install scipy>=0.12.0 \
      && pip install git+https://github.com/katholt/srst2@v0.2.0 \
      && sed -i -e 's/# \(en_GB\.UTF-8 .*\)/\1/' /etc/locale.gen \
      && touch /usr/share/locale/locale.alias \
      && locale-gen

# Perl locals
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL en_GB.UTF-8


# R dependencies
RUN Rscript -e "install.packages(c('BiocManager'), repos = '""${CRAN_URL}""'); BiocManager::install('Biostrings')"
RUN Rscript -e "install.packages('randomForest', repos = '""${CRAN_URL}""')"
RUN Rscript -e "install.packages('iterators', repos = '""${CRAN_URL}""')"
RUN Rscript -e "install.packages('foreach', repos = '""${CRAN_URL}""')"
RUN Rscript -e "install.packages('glmnet', repos = '""${CRAN_URL}""')"

# samtools compatible with srst2
RUN cd /tmp \
    && wget -q https://sourceforge.net/projects/samtools/files/samtools/0.1.18/samtools-0.1.18.tar.bz2/download -O samtools-0.1.18.tar.bz2 \
    && tar xf samtools-0.1.18.tar.bz2 \
    && cd samtools-0.1.18 \
    && make \
    && mv samtools /usr/local/bin \
    && cd /tmp \
    && rm -rf samtools*

# bowtie compatible with srst2
RUN cd /opt \
    && wget -q https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.9/bowtie2-2.2.9-linux-x86_64.zip/download -O bowtie2-2.2.9-linux-x86_64.zip \
    && unzip bowtie2-2.2.9-linux-x86_64.zip \
    && rm bowtie2-2.2.9-linux-x86_64.zip
ENV PATH="/opt/bowtie2-2.2.9:${PATH}"

# freebayes
RUN cd /tmp \
    && git clone --recursive  https://github.com/ekg/freebayes \
    && cd freebayes \
    && git checkout v1.3.2 \
    && make \
    && mv bin/freebayes /usr/local/bin \
    && cd /tmp \
    && rm -rf freebayes

# spn-resistance
COPY . /tmp/BUILD_SPN-Resistance_Sanger
RUN mkdir /opt/SPN-Resistance_Sanger \
    && cp /tmp/BUILD_SPN-Resistance_Sanger/*.pl /opt/SPN-Resistance_Sanger \
    && cp /tmp/BUILD_SPN-Resistance_Sanger/*.sh /opt/SPN-Resistance_Sanger \
    && cp -r /tmp/BUILD_SPN-Resistance_Sanger/bLactam_MIC_Rscripts /opt/SPN-Resistance_Sanger \
    && rm -rf /tmp/BUILD_SPN-Resistance_Sanger

ENV PATH="/opt/SPN-Resistance_Sanger:/opt/SPN-Resistance_Sanger/bLactam_MIC_Rscripts:${PATH}"
