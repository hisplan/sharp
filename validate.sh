#!/usr/bin/env bash

java -jar ~/Applications/womtool-45.1.jar \
    validate \
    sharp.wdl \
    --inputs sharp.inputs.json

java -jar ~/Applications/womtool-45.1.jar \
    validate \
    fastqc.wdl \
    --inputs fastqc.inputs.json
