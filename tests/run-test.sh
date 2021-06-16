#!/bin/bash -e

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  service account key (e.g. secrets.json)
    -m  module name (e.g. Velocyto)
EOF
}

while getopts "k:m:h" OPTION
do
    case $OPTION in
        k) service_account_key=$OPTARG ;;
        m) module_name=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$service_account_key" ] || [ -z "$module_name" ]
then
    usage
    exit 1
fi

# zip dependency
source ./zip-deps.sh

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl test.${module_name}.wdl \
    --inputs-files test.${module_name}.inputs.json \
    --deps-file ../Sharp.deps.zip \
    --label-file test.labels.json \
    --options-file test.options.aws.json
