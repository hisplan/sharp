#!/bin/bash

source config.sh

echo "${registry}/${image_name}:${version}"

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
