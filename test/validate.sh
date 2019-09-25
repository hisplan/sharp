#!/usr/bin/env bash

#hack: get dependency set up
ln -s ../modules/ modules

# java -jar ~/Applications/womtool.jar \
#     validate \
#     HelloWorld.wdl \
#     --inputs HelloWorld.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    MergeFastq.wdl \
    --inputs MergeFastq.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    FastQC.wdl \
    --inputs FastQC.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Cutadapt.wdl \
    --inputs Cutadapt.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    PrepCBWhitelist.wdl \
    --inputs PrepCBWhitelist.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Count.wdl \
    --inputs Count.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    HtoDemux.wdl \
    --inputs HtoDemux.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Combine.wdl \
    --inputs Combine.inputs.json

#hack: remove symblock link to dependency
unlink modules
