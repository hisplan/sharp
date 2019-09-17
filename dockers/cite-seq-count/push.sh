#!/bin/bash

docker login
docker tag cromwell-cite-seq-count:1.4.2-develop hisplan/cromwell-cite-seq-count:1.4.2-develop
docker push hisplan/cromwell-cite-seq-count:1.4.2-develop
