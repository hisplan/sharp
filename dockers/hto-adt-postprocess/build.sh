#!/bin/bash -e

source config.sh

if [ ! -r ./data/10x-hto-gex-mapper.pickle ]
then
    # pre-build 10x-hto-gex-mapper.pickle
    python hto_gex_mapper.py
fi

docker build -t ${image_name}:${version} .
