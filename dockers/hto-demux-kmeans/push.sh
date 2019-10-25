#!/bin/bash

docker login
docker tag cromwell-hto-demux-kmeans:0.2 hisplan/cromwell-hto-demux-kmeans:0.2
docker push hisplan/cromwell-hto-demux-kmeans:0.2
