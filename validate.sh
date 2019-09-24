#!/usr/bin/env bash

java -jar ~/Applications/womtool.jar \
    validate \
    HelloWorld.wdl \
    --inputs HelloWorld.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs Sharp.inputs.json
