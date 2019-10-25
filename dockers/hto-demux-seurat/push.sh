#!/bin/bash

docker login
docker tag cromwell-hto-demux-seurat:0.5 hisplan/cromwell-hto-demux-seurat:0.5
docker push hisplan/cromwell-hto-demux-seurat:0.5

