#!/usr/bin/env bash

# 10x v3 / TotalSeq-A
java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/IL10neg.inputs.json

java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/IL10pos.inputs.json

# indrop
java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/test-indrop-methanol.inputs.json

# 10x v3 / TotalSeq-B barcode translation
java -jar ~/Applications/womtool.jar \
    validate \
    Sharp.wdl \
    --inputs ./config/1973_HD1915_7xNK_FB_HTO.inputs.json

# cite-seq
java -jar ~/Applications/womtool.jar \
    validate \
    CiteSeq.wdl \
    --inputs ./config/2091_CS1429a_T_1_CD45pos_citeseq_2_CITE.inputs.json
