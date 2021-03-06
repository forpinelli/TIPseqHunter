FROM ubuntu:latest

# Set metadata
LABEL maintainer="tmiller@mochsl.org.br"

# Set environment variables
ENV SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 \
    SAMTOOLS_PATH=/samtools-1.7 \
    BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/archive/v2.2.3.tar.gz \
    BOWTIE2_PATH=/bowtie2-2.2.3

# Set PATH to find samtools
ENV PATH=${SAMTOOLS_PATH}:${PATH}

# Install core packages
# R: ggplot2, e1071, caret, pROC
# JAVA: Openjdk-7
# Compile: samtools, bowtie2
RUN apt-get update \
	&& apt-get install -y \
		autoconf \
		automake \
		bzip2 \
		gcc \
		g++ \
		gzip \
		make \
		libbz2-dev \
		liblzma-dev \
		libncurses5-dev \
		libtool \
		python-software-properties \
		r-base \
		r-base-core \
		r-cran-caret \
		r-cran-e1071 \
		r-cran-ggplot2 \
		software-properties-common \
		wget \
		zlib1g-dev \
	&& add-apt-repository -y ppa:openjdk-r/ppa \
	&& apt-get update \
	&& apt-get install -y openjdk-7-jdk \
	&& Rscript -e 'install.packages("pROC", dependencies = TRUE, repos="http://cloud.r-project.org/")' \
	&& wget ${SAMTOOLS_URL} && tar xjf samtools-1.7.tar.bz2 && (cd ${SAMTOOLS_PATH} && make) \
	&& wget ${BOWTIE2_URL} && tar xzf v2.2.3.tar.gz && (cd ${BOWTIE2_PATH} && make) \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add TIPseqHunter_data.tar.gz
ADD *.tar.gz /

# Add all TIPseqHunter executables
COPY *.sh /usr/bin/

# Set default command
CMD ["bash"]
