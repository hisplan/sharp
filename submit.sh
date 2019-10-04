#!/bin/bash

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  service account key (e.g. secrets.json)
EOF
}

while getopts "k:h" OPTION
do
    case $OPTION in
        k) service_account_key=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$service_account_key" ]
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
#         0  09-23-2019 18:41   modules/
#       669  09-23-2019 18:41   modules/HelloWorld.wdl
#      1064  09-23-2019 18:16   modules/MergeFastq.wdl
# ---------                     -------
#      1733                     3 files

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl Sharp.wdl \
    --inputs-files Sharp.inputs.json \
    --deps-file Sharp.deps.zip \
    --label-file Sharp.labels.json
