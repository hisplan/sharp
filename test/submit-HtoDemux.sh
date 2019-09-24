#!/bin/bash -e

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

if [ -z "$service_account_key" ] || [ ! -r "$service_account_key" ]
then
    usage
    exit 1
fi

# zip dependency
source ./zip-deps.sh

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl HtoDemux.wdl \
    --inputs-files HtoDemux.inputs.json \
    --deps-file ../Sharp.deps.zip \
    --label-file test.labels.json
