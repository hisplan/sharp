#!/bin/bash

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  service account key (e.g. secrets.json)
    -i  inputs file (e.g. sample.inputs.json)
EOF
}

while getopts "k:i:h" OPTION
do
    case $OPTION in
        k) service_account_key=$OPTARG ;;
        i) inputs_file=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$service_account_key" ] || [ -z "$inputs_file" ]
then
    usage
    exit 1
fi

rm -rf Sharp.deps.zip
zip Sharp.deps.zip modules modules/*

# $ unzip -l Sharp.deps.zip
# Archive:  Sharp.deps.zip
#   Length      Date    Time    Name
# ---------  ---------- -----   ----
#         0  10-08-2019 11:40   modules/
#      2657  09-26-2019 14:18   modules/Combine.wdl
#      1766  09-25-2019 15:36   modules/Count.wdl
#      1034  09-24-2019 11:46   modules/Cutadapt.wdl
#       668  09-24-2019 21:02   modules/FastQC.wdl
#       875  09-24-2019 21:01   modules/HtoDemux.wdl
#      1064  09-23-2019 18:16   modules/MergeFastq.wdl
#      2166  09-24-2019 19:54   modules/PrepCBWhitelist.wdl
# ---------                     -------
#     10230                     8 files

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl Sharp.wdl \
    --inputs-files ${inputs_file} \
    --deps-file Sharp.deps.zip \
    --label-file Sharp.labels.json
