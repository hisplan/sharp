#!/usr/bin/env bash

if [ -z $SCING_HOME ]
then
    echo "Environment variable 'SCING_HOME' not defined."
    exit 1
fi

echo ">> Hashtag 10x v3 / TotalSeq-A"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-10x-v3-tsa.inputs.json

echo ">> Hashtag 10x v3 / TotalSeq-B barcode translation"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-10x-v3-tsb.inputs.json

echo ">> Hashtag 10x / TotalSeq-C"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-10x-tsc.inputs.json

echo ">> Hashtag InDrop Methanol"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-indrop-methanol.inputs.json

echo ">> CITE-seq"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    CiteSeq.wdl \
    --inputs ./configs/citeseq.inputs.json

echo ">> CellPlex"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/cellplex.inputs.json

echo ">> ASAP-seq"
java -jar ${SCING_HOME}/devtools/womtool.jar \
    validate \
    AsapSeq.wdl \
    --inputs ./configs/asapseq-tsa.inputs.json
