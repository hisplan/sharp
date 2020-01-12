#!/bin/bash

docker login
docker tag cromwell-hto-demux-kmeans:0.3 hisplan/cromwell-hto-demux-kmeans:0.3
docker push hisplan/cromwell-hto-demux-kmeans:0.3
