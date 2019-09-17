#!/bin/bash

docker login
docker tag cromwell-seqc:0.2.3-alpha.5 hisplan/cromwell-seqc:0.2.3-alpha.5
docker push hisplan/cromwell-seqc:0.2.3-alpha.5
