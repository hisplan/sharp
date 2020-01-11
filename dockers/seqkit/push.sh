#!/bin/bash

docker login
docker tag cromwell-seqkit:0.11.0 hisplan/cromwell-seqkit:0.11.0
docker push hisplan/cromwell-seqkit:0.11.0
