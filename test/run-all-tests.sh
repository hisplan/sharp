#!/bin/bash -e

modules="MergeFastq FastQC Cutadapt PrepCBWhitelist Count HtoDemux Combine"

for module_name in $modules
do

    echo "Testing ${module_name}..."
    
    ./run-test.sh -k ~/secrets-gcp.json -m ${module_name}

done
