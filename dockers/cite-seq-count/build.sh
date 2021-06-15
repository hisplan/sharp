#!/bin/bash

source version.sh

docker build -t cromwell-cite-seq-count:${version} -f Dockerfile-${version} .
