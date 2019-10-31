#!/bin/bash

version="0.0.1"

#
# package it and push it to AWS S3
#

s3_dest="s3://dp-lab-home/software"

path_workdir=`mktemp -d`

# create installation script
cat <<EOF > ${path_workdir}/install.sh
#!/bin/bash

aws s3 cp --quiet s3://dp-lab-home/software/sharp-${version}.tar.gz .
mkdir -p sharp-${version}
tar xzf sharp-${version}.tar.gz -C sharp-${version}

echo "DONE."
EOF

tar cvzf ${path_workdir}/sharp-${version}.tar.gz \
    submit.sh Sharp.wdl Sharp.deps.zip Sharp.options.aws.json

aws s3 cp ${path_workdir}/sharp-${version}.tar.gz ${s3_dest}/
aws s3 cp ${path_workdir}/install.sh ${s3_dest}/install-sharp-${version}.sh

rm -rf ${path_workdir}
