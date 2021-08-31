#!/bin/bash -e

echo ">> 10x v3 / TotalSeq-A"
./submit-hashtag.sh \
    -k ~/keys/secrets-aws.json \
    -i configs/devtest/hashtag-10x-v3-tsa.inputs.json \
    -l configs/devtest/hashtag-10x-v3-tsa.labels.json \
    -o Sharp.options.aws.json

echo ">> 10x v3 / TotalSeq-B barcode translation"
./submit-hashtag.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/devtest/hashtag-10x-v3-tsb.inputs.json \
    -l configs/devtest/hashtag-10x-v3-tsb.labels.json \
    -o Sharp.options.aws.json

echo ">> CITE-seq"
./submit-citeseq.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/devtest/citeseq.inputs.json \
    -l configs/devtest/citeseq.labels.json \
    -o Sharp.options.aws.json

echo ">> ASAP-seq"
./submit-asapseq.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/devtest/asapseq-tsa.inputs.json \
    -l configs/devtest/asapseq-tsa.labels.json \
    -o Sharp.options.aws.json

echo ">> CellPlex"
./submit-cellplex.sh \
    -k ~/keys/cromwell-secrets-aws-nvirginia.json \
    -i configs/devtest/cellplex.inputs.json \
    -l configs/devtest/cellplex.labels.json \
    -o Sharp.options.aws.json
