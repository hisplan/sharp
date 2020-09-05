#!/bin/bash

docker login
docker tag cromwell-hto-demux-kmeans:0.4.0 hisplan/cromwell-hto-demux-kmeans:0.4.0
docker push hisplan/cromwell-hto-demux-kmeans:0.4.0
