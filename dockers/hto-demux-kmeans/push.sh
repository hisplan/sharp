#!/bin/bash

docker login
docker tag cromwell-hto-demux-kmeans:0.5.0 hisplan/cromwell-hto-demux-kmeans:0.5.0
docker push hisplan/cromwell-hto-demux-kmeans:0.5.0
