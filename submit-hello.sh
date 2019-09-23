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

if [ -z "$service_account_key" ] || [ ! -r "$service_account_key" ]
then
    usage
    exit 1
fi


# $ unzip -l hello.deps.zip
# Archive:  hello.deps.zip
#   Length      Date    Time    Name
# ---------  ---------- -----   ----
#         0  09-23-2019 14:51   modules/
#       669  09-23-2019 14:50   modules/hello.wdl
#      1051  09-23-2019 14:51   modules/merge-fastq.wdl
# ---------                     -------
#      1720                     3 files

zip hello.deps.zip modules modules/*

cromwell-tools submit \
    --secrets-file ${service_account_key} \
    --wdl hello.wdl \
    --inputs-files hello.inputs.json \
    --deps-file hello.deps.zip
