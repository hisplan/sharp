#!/bin/bash -e

source config.sh

docker build -t ${image_name}:${version} .
