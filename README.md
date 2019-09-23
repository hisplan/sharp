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


## Running on AWS

### Step 1

Start the Cromwell Server (EC2 instance), SSH into the server, run `supervisord` which brings up the Cromwell in server mode.

### Step 2

Get the address of Cromwell Server, update the configuration using this address:

```bash
$ cat /Users/chunj/jmui/bin
#!/usr/bin/env bash
if docker ps | grep job-manager
then
echo 'Stopping current instance(s)'
docker stop $(docker ps | grep 'job-manager' | awk '{ print $1 }')
fi
export CROMWELL_URL='http://ec2-100-26-170-43.compute-1.amazonaws.com/api/workflows/v1'
docker-compose -f /Users/chunj/jmui/bin/docker-compose.yml up
```

Run Job Manager (currently installed locally)

```bash
$ /Users/chunj/jmui/bin/jmui_start.sh
```

Open a browser and access Job Manager at `http://localhost:4200/jobs`

## Running on GCP

### Step 1

Start the Cromwell Server, SSH into the server, run the following:

```bash
$ screen -S server
$ java -Dconfig.file=google.JES.conf -jar cromwell-45.1.jar server
```

### Step 2

Get the address of Cromwell Server, update the configuration using this address:

```bash
$ cat /Users/chunj/jmui/bin
#!/usr/bin/env bash
if docker ps | grep job-manager
then
echo 'Stopping current instance(s)'
docker stop $(docker ps | grep 'job-manager' | awk '{ print $1 }')
fi
export CROMWELL_URL='http://ec2-100-26-170-43.compute-1.amazonaws.com/api/workflows/v1'
docker-compose -f /Users/chunj/jmui/bin/docker-compose.yml up
```

Run Job Manager (currently installed locally)

```bash
$ /Users/chunj/jmui/bin/jmui_start.sh
```

Open a browser and access Job Manager at `http://localhost:4200/jobs`


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
