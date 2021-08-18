#!/bin/bash -e

modules="ReformatFastq CountReads AnnData-ToAnnData AnnData-UpdateAnnData Preprocess TranslateBarcodes SanityCheck CutInDropSpacer MergeFastq FastQC Cutadapt PrepCBWhitelist Count HtoDemuxSeurat HtoDemuxKMeans Combine"

for module_name in $modules
do

    echo "Testing ${module_name}..."
    
    ./run-test.sh -k ~/secrets-gcp.json -m ${module_name}

done
