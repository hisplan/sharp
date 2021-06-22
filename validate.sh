#!/usr/bin/env bash

echo ">> 10x v3 / TotalSeq-A"
java -jar ~/Applications/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-10x-v3-totalseq-A.inputs.json

echo ">> 10x v3 / TotalSeq-B barcode translation"
java -jar ~/Applications/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-10x-v3-totalseq-B.inputs.json

echo ">> InDrop Methanol"
java -jar ~/Applications/womtool.jar \
    validate \
    Hashtag.wdl \
    --inputs ./configs/hashtag-indrop-methanol.inputs.json

echo ">> CITE-seq"
java -jar ~/Applications/womtool.jar \
    validate \
    CiteSeq.wdl \
    --inputs ./configs/citeseq.inputs.json
