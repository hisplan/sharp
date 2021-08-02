#!/bin/bash

source config.sh

echo "${registry}/${image_name}:${version}"

scing push --image=${registry}/${image_name}:${version}
