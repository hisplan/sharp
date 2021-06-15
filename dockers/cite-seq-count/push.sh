#!/bin/bash

source version.sh

docker login
docker tag cromwell-cite-seq-count:${version} hisplan/cromwell-cite-seq-count:${version}
docker push hisplan/cromwell-cite-seq-count:${version}
