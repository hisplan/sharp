#!/bin/bash -e

echo ">> 10x v3 / TotalSeq-A"
./submit-hashtag.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/hashtag-10x-v3-tsa.inputs.json \
    -l configs/hashtag-10x-v3-tsa.labels.json \
    -o Sharp.options.aws.json

echo ">> 10x v3 / TotalSeq-B barcode translation"
./submit-hashtag.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/hashtag-10x-v3-tsb.inputs.json \
    -l configs/hashtag-10x-v3-tsb.labels.json \
    -o Sharp.options.aws.json

echo ">> CITE-seq"
./submit-citeseq.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/citeseq.inputs.json \
    -l configs/citeseq.labels.json \
    -o Sharp.options.aws.json

echo ">> ASAP-seq"
./submit-asapseq.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/asapseq-tsa.inputs.json \
    -l configs/asapseq-tsa.labels.json \
    -o Sharp.options.aws.json

echo ">> Cell Plex"
./submit-cellplex.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/cellplex.inputs.json \
    -l configs/cellplex.labels.json \
    -o Sharp.options.aws.json
