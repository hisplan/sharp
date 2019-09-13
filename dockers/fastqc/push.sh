#!/bin/bash

docker login
docker tag cromwell-fastqc:0.11.8 hisplan/cromwell-fastqc:0.11.8
docker push hisplan/cromwell-fastqc:0.11.8

