FROM ubuntu:18.04

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

RUN apt-get update \
    && apt-get install --yes build-essential python3 python3-pip

RUN apt-get install --yes wget zlib1g-dev libbz2-dev liblzma-dev

RUN pip3 install pandas numpy scipy sklearn

COPY combine.py /opt/combine.py
COPY correct_fp_doublets.py /opt/correct_fp_doublets.py

WORKDIR /opt
