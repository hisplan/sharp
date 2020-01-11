#!/bin/bash

docker login
docker tag cromwell-cut-indrop-spacer:0.2 hisplan/cromwell-cut-indrop-spacer:0.2
docker push hisplan/cromwell-cut-indrop-spacer:0.2
