#!/bin/bash

source version.sh

docker run -it --rm \
    cromwell-cite-seq-count:${version} CITE-seq-Count --help

docker run -it --rm \
    cromwell-cite-seq-count:${version} CITE-seq-Count --version
