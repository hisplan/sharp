FROM openjdk:8-jre

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

ENV FASTQC_VERSION 0.11.8

RUN apt-get update \
    && apt-get install --yes unzip perl

RUN cd /tmp \
    && wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${FASTQC_VERSION}.zip \
    && unzip /tmp/fastqc_v${FASTQC_VERSION}.zip \
    && mv /tmp/FastQC /opt/ \
    && chmod 755 /opt/FastQC/fastqc \
    && ln -s /opt/FastQC/fastqc /usr/local/bin/fastqc \
    && rm -rf /tmp/*

ENTRYPOINT ["/usr/local/bin/fastqc"]
CMD ["--help"]
