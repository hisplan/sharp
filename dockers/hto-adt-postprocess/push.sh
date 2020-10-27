#!/bin/bash

docker login
docker tag cromwell-hto-adt-postprocess:0.3.1 hisplan/cromwell-hto-adt-postprocess:0.3.1
docker push hisplan/cromwell-hto-adt-postprocess:0.3.1
