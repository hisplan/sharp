#!/usr/bin/env bash

java -jar ~/Applications/womtool-40.jar \
    validate \
    sharp.wdl \
    --inputs sharp.inputs.json
