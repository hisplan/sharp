#!/bin/bash

docker login
docker tag cromwell-cutadapt:2.5 hisplan/cromwell-cutadapt:2.5
docker push hisplan/cromwell-cutadapt:2.5
