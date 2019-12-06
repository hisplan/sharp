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

## Running Workflow

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

Finally, submit your job:

```bash
$ ./submit.sh -k ~/secrets.json
```
