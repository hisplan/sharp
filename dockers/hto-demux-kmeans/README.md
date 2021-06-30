# hto-demux-kmeans

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hto-demux-kmeans:0.5.0
```

```bash
$ python3 demux_kmeans.py \
    --hto-umi-count-dir /data/umi_count \
    --min-count 0 \
    --mode 1
```
