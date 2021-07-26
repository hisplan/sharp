#!/bin/bash

skip_download="False"

usage()
{
cat << EOF
USAGE: `basename $0` [options]
    -k  service account key (e.g. secrets.json)
    -t  type ('hashtag', 'citeseq', 'asapseq', or 'cellplex')
    -w  workflow ID
    -s  skip download and use the pre-downloaded data
EOF
}

while getopts "k:t:w:sh" OPTION
do
    case $OPTION in
        k) service_account_key=$OPTARG ;;
        t) type=$OPTARG ;;
        w) workflow_id=$OPTARG ;;
        s) skip_download="True" ;;
        h) usage; exit 1 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$service_account_key" ] || [ -z "$workflow_id" ]
then
    usage
    exit 1
fi

if [ "$type" != "hashtag" ] && [ "$type" != "citeseq" ] && [ "$type" != "asapseq" ] && [ "$type" != "cellplex" ]
then
    usage
    exit 1
fi

path_base_data="./${type}"

mkdir -p ${path_base_data}

temp_file=`uuidgen`.ipynb

# run download.ipynb to download necessary data
papermill download-v2.ipynb ${temp_file} \
    --parameters workflow_name ${type} \
    --parameters workflow_id ${workflow_id} \
    --parameters path_secrets_file ${service_account_key} \
    --parameters path_base_data ${path_base_data} \
    --parameters skip_download ${skip_download} \
    --stdout-file ${workflow_id}.sample_name.txt

# get sample name (download.ipynb outputs)
sample_name=`tail -1 ${workflow_id}.sample_name.txt`

# delete (we don't want to keep this file)
rm -rf ${temp_file}
rm -rf ${workflow_id}.sample_name.txt

path_out="${path_base_data}/${sample_name}/${workflow_id}"

# copy dependency to make the final notebook standalone
cp dna3bit.py ${path_out}/

# asapseq and cellplex share the same hashtag inspection notebook
if [ "$type" == "asapseq" ] || [ "$type" == "cellplex" ]
then
    type="hashtag"
fi

# run inspect-*-v2.ipynb to inspect data
papermill inspect-${type}-v2.ipynb ${path_out}/automated-inspection.ipynb \
    --cwd ${path_out} \
    --parameters workflow_id ${workflow_id} \
    --parameters sample_name ${sample_name} \
    --parameters path_data .

if [ ${type} == "hashtag" ]
then
    papermill hashtag-classify-negative.ipynb ${path_out}/negative-classified.ipynb \
        --cwd ${path_out} \
        --parameters workflow_id ${workflow_id} \
        --parameters sample_name ${sample_name} \
        --parameters path_data .
fi
