#!/bin/bash -e

source config.sh

docker build -t ${image_name}:${version} .

# hack: comment the ENTRYPOINT and CMD lines to make it work for cromwell
# this will generate `Dockerfile.cromwell` and build it under the name `cromwell-${image_name}:${version}`
# https://github.com/broadinstitute/cromwell/issues/2461
cat Dockerfile \
    | sed 's/^ENTRYPOINT \[/# ENTRYPOINT \[/g' \
    | sed 's/^CMD \[/# CMD \[/g' > Dockerfile.cromwell

# build it
docker build -t cromwell-${image_name}:${version} -f Dockerfile.cromwell .
