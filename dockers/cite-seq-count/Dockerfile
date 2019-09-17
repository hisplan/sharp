FROM ubuntu:18.04

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

ENV CITE_SEQ_COUNT_VERSION 1.4.2-develop

RUN apt-get update \
    && apt-get install --yes build-essential python3 python3-pip

RUN apt-get install --yes wget zlib1g-dev libbz2-dev liblzma-dev

RUN cd /tmp \
    && wget https://github.com/hisplan/CITE-seq-Count/archive/${CITE_SEQ_COUNT_VERSION}.tar.gz \
    && tar xvzf ${CITE_SEQ_COUNT_VERSION}.tar.gz \
    && cd CITE-seq-Count-${CITE_SEQ_COUNT_VERSION} \
    && pip3 install .

# ENTRYPOINT ["/usr/local/bin/cutadapt"]
# CMD ["--help"]
