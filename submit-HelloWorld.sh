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

rm -rf HelloWorld.deps.zip
zip HelloWorld.deps.zip modules modules/HelloWorld.wdl

# $ unzip -l HelloWorld.deps.zip
# Archive:  HelloWorld.deps.zip
#   Length      Date    Time    Name
# ---------  ---------- -----   ----
#         0  09-23-2019 14:51   modules/
#       669  09-23-2019 14:50   modules/HelloWorld.wdl
# ---------                     -------
#       669                     2 files

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl HelloWorld.wdl \
    --inputs-files HelloWorld.inputs.json \
    --deps-file HelloWorld.deps.zip
