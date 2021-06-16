#!/bin/bash -e

echo ">> 10x v3 / TotalSeq-A"
./submit-hashtag.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/hashtag-10x-v3-totalseq-A.inputs.json \
    -l configs/hashtag-10x-v3-totalseq-A.labels.json \
    -o Sharp.options.aws.json

echo ">> 10x v3 / TotalSeq-B barcode translation"
./submit-hashtag.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/hashtag-10x-v3-totalseq-B.inputs.json \
    -l configs/hashtag-10x-v3-totalseq-B.labels.json \
    -o Sharp.options.aws.json

echo ">> CITE-seq"
./submit-citeseq.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/citeseq.inputs.json \
    -l configs/citeseq.labels.json \
    -o Sharp.options.aws.json
