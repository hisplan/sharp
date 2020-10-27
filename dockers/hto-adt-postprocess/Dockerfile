FROM ubuntu:20.04

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

RUN apt-get update \
    && apt-get install --yes build-essential python3 python3-pip

RUN apt-get install --yes wget zlib1g-dev libbz2-dev liblzma-dev

RUN pip3 install pandas numpy pyyaml scipy sklearn tqdm scanpy==1.6.0

# code
COPY combine.py /opt/combine.py
COPY dna3bit.py /opt/dna3bit.py
COPY translate_barcodes.py /opt/translate_barcodes.py
COPY citeseq_to_adata.py /opt/citeseq_to_adata.py

# data
COPY ./data/3M-february-2018.txt.gz /opt/data/

WORKDIR /opt
