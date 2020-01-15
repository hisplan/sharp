#!/bin/bash

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  service account key (e.g. secrets.json)
    -w  workflow ID
EOF
}

while getopts "k:w:h" OPTION
do
    case $OPTION in
        k) service_account_key=$OPTARG ;;
        w) workflow_id=$OPTARG ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$service_account_key" ] || [ -z "$workflow_id" ]
then
    usage
    exit 1
fi

path_base_data="./data"

mkdir -p ${path_base_data}

temp_file=`uuidgen`.ipynb

# run download.ipynb to download necessary data
papermill download.ipynb ${temp_file} \
    --parameters workflow_id ${workflow_id} \
    --parameters path_secrets_file ${service_account_key} \
    --parameters path_base_data ${path_base_data} \
    --stdout-file ${workflow_id}.sample_name.txt

# get sample name (download.ipynb outputs)
sample_name=`tail -1 ${workflow_id}.sample_name.txt`

# delete (we don't want to keep this file)
rm -rf ${temp_file}
rm -rf ${workflow_id}.sample_name.txt

path_out="${path_base_data}/${sample_name}/${workflow_id}"

# copy dependency to make the final notebook standalone
cp dna3bit.py ${path_out}/

# run inspect.ipynb to inspect data
papermill inspect.ipynb ${path_out}/automated-inspection-outputs.ipynb \
    --cwd ${path_out} \
    --parameters workflow_id ${workflow_id} \
    --parameters sample_name ${sample_name} \
    --parameters path_data .
