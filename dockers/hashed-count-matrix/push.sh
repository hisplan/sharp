#!/bin/bash

docker login
docker tag cromwell-hashed-count-matrix:0.2.0 hisplan/cromwell-hashed-count-matrix:0.2.0
docker push hisplan/cromwell-hashed-count-matrix:0.2.0
