# sharp

A single-cell demultiplexing pipeline.

the sharp (♯) from musical notation similar to the hash (#) in hashtag.

Sharp supports the following:

- Hashtag
- CITE-seq
- ASAP-seq
- CellPlex

## Outputs

In addition to cell barcode/UMI correction and quantification, cells are demultiplexed to their sample-of-origin and cross-sample doublets are identified (except CITE-seq). More information about the outputs can be found [here](docs/understanding-outputs-2021-08-30.pdf)

## Setup

Sharp is a part of SCING (Single-Cell pIpeliNe Garden; pronounced as "sing" /siŋ/). For setup, please refer to [this page](https://github.com/hisplan/scing). All the instructions below is given under the assumption that you have already configured SCING in your environment.

## Running Workflow

### Hashtag

```bash
conda activate scing

./submit-hashtag.sh \
  -k ~/keys/cromwell-secrets.json \
  -i configs/hashtag-10x-v3-tsb.inputs.json \
  -l configs/hashtag-10x-v3-tsb.labels.json \
  -o Sharp.options.aws.json
```

### CITE-SEQ

```bash
conda activate scing

./submit-citeseq.sh \
  -k ~/keys/cromwell-secrets.json \
  -i configs/citeseq.inputs.json \
  -l configs/citeseq.labels.json \
  -o Sharp.options.aws.json
```

### ASAP-seq

```bash
conda activate scing

./submit-asapseq.sh \
  -k ~/keys/cromwell-secrets.json \
  -i configs/asapseq-tsa.inputs.json \
  -l configs/asapseq-tsa.labels.json \
  -o Sharp.options.aws.json
```

### CellPlex

```bash
conda activate scing

./submit-cellplex.sh \
  -k ~/keys/cromwell-secrets.json \
  -i configs/cellplex.inputs.json \
  -l configs/cellplex.labels.json \
  -o Sharp.options.aws.json
```

## Manual Inspection

Jupyter Notebook and Papermill are required.

```bash
$ conda create -n sharp python=3.8 pip
$ conda activate sharp
$ cd manual-inspection
$ pip install -r requirements.txt
$ ./run.sh
USAGE: run.sh [options]
    -k  service account key (e.g. secrets.json)
    -t  type ('hashtag', 'citeseq', 'asapseq', or 'cellplex')
    -w  workflow ID
    -s  skip download and use the pre-downloaded data
```

```bash
$ ./run.sh -k ~/keys/cromwell-secrets.json -t hashtag -w 47080814-0fe7-458d-9edb-5e3cb86bf870
```
