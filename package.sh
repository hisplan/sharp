#!/bin/bash

version="0.0.1"

#
# package it and push it to AWS S3
#

s3_dest="s3://dp-lab-home/software"

path_workdir=`mktemp -d`

tar cvzf ${path_workdir}/sharp-${version}.tar.gz \
    submit.sh Sharp.wdl Sharp.deps.zip Sharp.options.*.json

aws s3 cp ${path_workdir}/sharp-${version}.tar.gz ${s3_dest}/

rm -rf ${path_workdir}
