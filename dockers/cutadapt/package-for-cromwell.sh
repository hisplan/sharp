#!/bin/bash

source config.sh

image_name="cromwell-${image_name}"

echo "Building ${image_name}:${version}..."

# hack: comment the ENTRYPOINT and CMD lines
# https://github.com/broadinstitute/cromwell/issues/2461
cat Dockerfile \
    | sed 's/^ENTRYPOINT \[/# ENTRYPOINT \[/g' \
    | sed 's/^CMD \[/# CMD \[/g' > Dockerfile.cromwell

cat Dockerfile.cromwell

# build it
docker build -t ${image_name}:${version} -f Dockerfile.cromwell .

echo "Packaging ${registry}/${image_name}:${version}..."

#
# tag it and push it to docker hub
#

docker tag ${image_name}:${version} ${registry}/${image_name}:${version}
if [ $create_ecr_repo == 1 ]
then
    # only create if not exist
    aws ecr describe-repositories --repository-name ${image_name} 2> /dev/null
    if [ $? != 0 ]
    then
        aws ecr create-repository --repository-name ${image_name}
    fi
fi
docker push ${registry}/${image_name}:${version}
