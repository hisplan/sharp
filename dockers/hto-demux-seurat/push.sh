#!/bin/bash

docker login
docker tag cromwell-hto-demux-seurat:0.6.0 hisplan/cromwell-hto-demux-seurat:0.6.0
docker push hisplan/cromwell-hto-demux-seurat:0.6.0
