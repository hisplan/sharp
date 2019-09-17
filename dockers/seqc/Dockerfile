FROM centos:7

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.seqc="0.2.3-alpha.5" \
      version.star="2.5.3a" \
      version.samtools="1.3.1" \
      source.seqc="https://github.com/hisplan/seqc/releases/tag/v0.2.3-alpha.5" \
      source.star="https://github.com/alexdobin/STAR/releases/tag/2.5.3a" \
      source.samtools="https://github.com/samtools/samtools/releases/tag/1.3.1"

ENV SEQC_VERSION 0.2.3-alpha.5
ENV MINICONDA_VERSION 4.5.1
ENV STAR_VERSION 2.5.3a
ENV SAMTOOLS_VERSION 1.3.1

ENV LC_ALL en_US.utf-8
ENV PATH="/opt/conda/bin:${PATH}"

# SEQC requires this
ENV TMPDIR "/tmp"

RUN yum group install -y "Development Tools" \
    && cd /tmp \
    && curl -O https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -b -p /opt/conda \
    && rm -rf Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && pip install --upgrade pip

RUN cd /tmp \
    && curl -OL https://github.com/alexdobin/STAR/archive/${STAR_VERSION}.tar.gz \
    && tar -xf ${STAR_VERSION}.tar.gz \
    && cp STAR-${STAR_VERSION}/bin/Linux_x86_64_static/STAR /usr/bin/

RUN cd /tmp \
    && yum install -y zlib-devel ncurses-devel \
    && curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && tar xjvf samtools-${SAMTOOLS_VERSION}.tar.bz2 \
    && cd samtools-${SAMTOOLS_VERSION} \
    && make \
    && mv samtools /usr/bin/

# fixme: contact the author to release a tag and install a specific version
RUN pip install git+https://github.com/jacoblevine/phenograph.git

RUN cd /opt \
    && yum install -y cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel pigz \
    && yum install -y mutt \
    && pip install Cython \
    && pip install numpy \
    && pip install bhtsne \
    && curl -OL https://github.com/hisplan/seqc/archive/v${SEQC_VERSION}.tar.gz \
    && tar xvzf v${SEQC_VERSION}.tar.gz \
    && rm -rf v${SEQC_VERSION}.tar.gz \
    && cd seqc-${SEQC_VERSION} \
    && pip install . \
    && cp `python -c "import site; print(site.getsitepackages()[0])"`/matplotlib/mpl-data/fonts/ttf/DejaVuS* /usr/share/fonts/ \
    && fc-cache -fv

RUN rm -rf /tmp/*

WORKDIR /root/

# ENTRYPOINT ["SEQC"]
# CMD ["-h"]

# install development tools which contains e.g. gcc
# install miniconda v4.5.1 which comes with Python 3.6.5 + pip
# install the SEQC dependencies
