#!/usr/bin/env bash

java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/IL10neg.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/IL10pos.inputs.json
