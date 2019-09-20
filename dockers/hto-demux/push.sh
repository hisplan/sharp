#!/bin/bash

docker login
docker tag cromwell-hto-demux:0.1 hisplan/cromwell-hto-demux:0.1
docker push hisplan/cromwell-hto-demux:0.1

