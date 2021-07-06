# sharp

A hashtag & CITE-seq pipeline.

the sharp (♯) from musical notation similar to the hash (#) in hashtag.

## Outputs

We do more than just CB/UMI correction/counting. Essentially, we demultiplex cells to their sample-of-origin and identify cross-sample doublets. And we combine with scRNA-seq data so that users can easily identify which cells belongs to which sample.

Explanation about the output:

- HashedCountMatrix
  - `final-classification.tsv.gz`: tells you which cell belongs to which hashtag.
  - `final-matrix.tsv.gz`: a cell x gene matrix from scRNA-seq + one additional column that tells you which hashtag a given cell belongs to.
  - `stats.yml`: tells you how many cells belongs to each hashtag.
- CiteSeqCount
  - This may contain one or more files only for troubleshooting purpose.

## Components

- FASTQ merge (multiple lanes)
- QC on raw FASTQ
- FASTQ trimming
- Reducing barcode whitelist (or get from scRNA-seq)
- Creating cell-by-hashtag matrix
- Demultiplexing
- Combining with scRNA-seq matrix

## Setup

```bash
aws s3 cp s3://dp-lab-home/software/install-sharp-0.0.8.sh - | bash
```

```
$ conda create -n cromwell python=3.7.7 pip
$ conda activate cromwell
$ conda install -c cyclus java-jre
$ pip install cromwell-tools
```

Update `secrets.json` with the new Cromwell Server address:

```bash
$ cat ~/secrets.json
{
    "url": "http://ec2-100-26-170-43.compute-1.amazonaws.com",
    "username": "****",
    "password": "****"
}
```

## Running Workflow

Finally, submit your job:

### Hashtag

```bash
conda activate cromwell

./submit-hashtag.sh \
    -k ~/secrets-aws.json \
    -i configs/PBMC_v2_Meth_Hash_2_ADT.inputs.json \
    -l configs/PBMC_v2_Meth_Hash_2_ADT.labels.json \
    -o Sharp.options.aws.json
```

### CITE-SEQ

```bash
conda activate cromwell

./submit-citeseq.sh \
    -k ~/secrets-aws.json \
    -i configs/PBMC_v2_Meth_Hash_2_ADT.inputs.json \
    -l configs/PBMC_v2_Meth_Hash_2_ADT.labels.json \
    -o Sharp.options.aws.json
```

## Manual Inspection

Jupyter Notebook and Papermill are required.

```
$ conda activate dev

$ cd manual-inspection
$ ./run.sh -k ~/secrets-aws.json -t hashtag -w 47080814-0fe7-458d-9edb-5e3cb86bf870
```

## Unit Test

IL10neg

```yaml
Doublet: 1433
HTO-301: 6615
HTO-302: 1566
HTO-303: 2049
HTO-304: 1312
Total: 12975
```

IL10pos

```yaml
Doublet: 367
HTO-301: 6906
HTO-302: 1441
HTO-303: 157
HTO-304: 90
Total: 8961
```
