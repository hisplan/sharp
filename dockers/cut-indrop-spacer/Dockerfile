FROM ubuntu:20.04

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

ENV BIOPYTHON_VERSION 1.76

# hack: to avoid Failed to fetch"
RUN sed -i'' 's/archive\.ubuntu\.com/us\.archive\.ubuntu\.com/' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install --yes build-essential python3 python3-pip

RUN pip3 install biopython==${BIOPYTHON_VERSION}

COPY cut_indrop_spacer.py /opt/cut_indrop_spacer.py

WORKDIR /opt
