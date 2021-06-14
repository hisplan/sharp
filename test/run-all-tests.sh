#!/bin/bash -e

modules="ToAnnData Preprocess TranslateBarcodes QC CutInDropSpacer MergeFastq FastQC Cutadapt PrepCBWhitelist Count HtoDemuxSeurat HtoDemuxKMeans Combine"

for module_name in $modules
do

    echo "Testing ${module_name}..."
    
    ./run-test.sh -k ~/secrets-gcp.json -m ${module_name}

done
