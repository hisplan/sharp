#!/bin/bash -e

version="0.0.7"

#
# package it and push it to AWS S3
#

s3_dest="s3://dp-lab-home/software"

path_workdir=`mktemp -d`

echo $path_workdir

# create installation script
cat <<EOF > ${path_workdir}/install.sh
#!/bin/bash

aws s3 cp --quiet s3://dp-lab-home/software/sharp-${version}.tar.gz .
mkdir -p sharp-${version}
tar xzf sharp-${version}.tar.gz -C sharp-${version}

echo "DONE."
EOF

tar cvzf ${path_workdir}/sharp-${version}.tar.gz \
    submit-hashtag.sh submit-citeseq.sh Sharp.deps.zip Hashtag.wdl CiteSeq.wdl Sharp.options.aws.json

aws s3 cp ${path_workdir}/sharp-${version}.tar.gz ${s3_dest}/
aws s3 cp ${path_workdir}/install.sh ${s3_dest}/install-sharp-${version}.sh

rm -rf ${path_workdir}
