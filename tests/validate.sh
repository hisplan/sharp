#!/usr/bin/env bash

#hack: get dependency set up
ln -s ../modules/ modules

modules="CountReads ToAnnData Preprocess TranslateBarcodes QC CutInDropSpacer MergeFastq FastQC Cutadapt PrepCBWhitelist Count HtoDemuxSeurat HtoDemuxKMeans Combine"

for module_name in $modules
do

    echo "Validating ${module_name}..."

    java -jar ~/Applications/womtool.jar \
        validate \
        test.${module_name}.wdl \
        --inputs test.${module_name}.inputs.json


done

#hack: remove symblock link to dependency
unlink modules
