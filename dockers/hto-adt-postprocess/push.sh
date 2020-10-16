#!/bin/bash

docker login
docker tag cromwell-hto-adt-postprocess:0.3.0 hisplan/cromwell-hto-adt-postprocess:0.3.0
docker push hisplan/cromwell-hto-adt-postprocess:0.3.0
