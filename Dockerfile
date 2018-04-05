FROM openjdk:7

# Set metadata
LABEL maintainer="tmiller@mochsl.org.br"

# Set environment variables
ENV SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 \
    SAMTOOLS_PATH=/samtools-1.7 \
    BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/archive/v2.2.3.tar.gz \
    BOWTIE2_PATH=/bowtie2-2.2.3 \
    PATH=$SAMTOOLS_PATH:$PATH

# Install core packages
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    bzip2 \
    gcc \
    g++ \
    gzip \
    pigz \
    make \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    libtool \
    r-base \
    wget \
    zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install R packages
RUN Rscript -e 'install.packages(c("pROC, ggplot2, caret, e1071"), repos="http://cloud.r-project.org/")'

# Download samtools v1.7 and compile
RUN wget $SAMTOOLS_URL && tar xjf samtools-1.7.tar.bz2 && (cd $SAMTOOLS_PATH && make)

# Download bowtie v2.2.3 and compile
RUN wget $BOWTIE2_URL && tar xzf v2.2.3.tar.gz && (cd $BOWTIE2_PATH && make)

# Add TIPseqHunter_data.tar.gz
ADD *.tar.gz /

# Add all TIPseqHunter executables
COPY *.sh /usr/bin/

# Set default command
CMD ["bash"]
