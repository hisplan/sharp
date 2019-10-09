#!/bin/bash

docker login
docker tag cromwell-hto-demux-kmeans:0.1 hisplan/cromwell-hto-demux-kmeans:0.1
docker push hisplan/cromwell-hto-demux-kmeans:0.1
