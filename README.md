# sharp

A hashtag pipeline.

the sharp (♯) from musical notation similar to the hash (#) in hashtag.


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
aws s3 cp s3://dp-lab-home/software/install-sharp-0.0.1.sh - | bash
```

```
$ conda create -n cromwell python=3.6.5 pip
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

```bash
conda activate cromwell

./submit.sh \
    -k ~/secrets-aws.json \
    -i config/PBMC_v2_Meth_Hash_2_ADT.inputs.json \
    -l config/PBMC_v2_Meth_Hash_2_ADT.labels.json \
    -o Sharp.options.aws.json
```

## Manual Inspection

Jupyter Notebook and Papermill are required.

```
$ conda activate dev

$ cd manual-inspection
$ ./run.sh -k ~/secrets-aws.json -w 47080814-0fe7-458d-9edb-5e3cb86bf870
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
