#!/bin/bash

docker login
docker tag cromwell-hashed-count-matrix:0.1 hisplan/cromwell-hashed-count-matrix:0.1
docker push hisplan/cromwell-hashed-count-matrix:0.1
