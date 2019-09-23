#!/usr/bin/env bash

java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs Sharp.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    fastqc.wdl \
    --inputs fastqc.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    cutadapt.wdl \
    --inputs cutadapt.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    prep-cb-whitelist.wdl \
    --inputs prep-cb-whitelist.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    count.wdl \
    --inputs count.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    hto-demux.wdl \
    --inputs hto-demux.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    combine.wdl \
    --inputs combine.inputs.json
