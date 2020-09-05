FROM hisplan/seurat:3.2.0

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

RUN apt-get update \
    && apt-get install -y python3 python3-pip

RUN apt-get install -y wget zlib1g-dev libbz2-dev liblzma-dev

# copy script that installs R packages
COPY install-packages.R /opt/install-packages.R

# install packages
RUN Rscript --vanilla /opt/install-packages.R

RUN pip3 install pandas numpy pyyaml scipy sklearn

COPY hto-demux.R /opt/hto-demux.R
COPY correct_fp_doublets.py /opt/correct_fp_doublets.py
COPY dna3bit.py /opt/dna3bit.py

WORKDIR /opt
