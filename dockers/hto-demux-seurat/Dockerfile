FROM ubuntu:18.10

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

# non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# enable source repositories to install deps for R and update the apt-get list
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && apt-get update

RUN apt-get update \
    && apt-get install -y build-essential r-base

RUN apt-get install -y libcurl4-openssl-dev libssl-dev

# copy script that installs R packages
COPY install-packages.R /opt/install-packages.R

# install packages
RUN Rscript --vanilla /opt/install-packages.R

COPY hto-demux.R /opt/hto-demux.R
