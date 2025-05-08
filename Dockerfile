FROM ubuntu:focal

LABEL \
  version="3.3.6" \
  description="Docker image to run AnnotSV" \
  maintainer="Alexander Paul <alex.paul@wustl.edu>"

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  g++ \
  libbz2-dev \
  liblzma-dev \
  make \
  python3 \
  python3-pip \
  tar \
  tcl \
  tcllib \
  unzip \
  wget \
  zlib1g-dev

ENV BEDTOOLS_INSTALL_DIR=/opt/bedtools2
ENV BEDTOOLS_VERSION=2.31.1

RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /tmp
RUN wget https://github.com/arq5x/bedtools2/releases/download/v$BEDTOOLS_VERSION/bedtools-$BEDTOOLS_VERSION.tar.gz && \
  tar -zxf bedtools-$BEDTOOLS_VERSION.tar.gz && \
  rm -f bedtools-$BEDTOOLS_VERSION.tar.gz && \
  cd bedtools2 && \
  make && \
  mkdir --parents $BEDTOOLS_INSTALL_DIR && \
  mv ./* $BEDTOOLS_INSTALL_DIR && \
  cd / && \
  ln -s $BEDTOOLS_INSTALL_DIR/bin/* /usr/bin/ && \
  rm -rf /tmp/bedtools2

ENV BCFTOOLS_VERSION=1.21
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  cd /tmp/bcftools-$BCFTOOLS_VERSION && \
  make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install && \
  ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/local/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION /tmp/bcftools-$BCFTOOLS_VERSION.tar.bz2


ENV ANNOTSV_VERSION=3.3.6
ENV ANNOTSV=/opt/AnnotSV_$ANNOTSV_VERSION

WORKDIR /opt
RUN wget https://github.com/lgmgeo/AnnotSV/archive/refs/tags/v${ANNOTSV_VERSION}.tar.gz && \
  tar -zxf v${ANNOTSV_VERSION}.tar.gz && \
  mv AnnotSV-${ANNOTSV_VERSION} ${ANNOTSV} && \
  rm v${ANNOTSV_VERSION}.tar.gz

ENV PATH="${ANNOTSV}/bin:${PATH}"

RUN make PREFIX=$ANNOTSV install-variantconvert --makefile=${ANNOTSV}/Makefile


WORKDIR /
