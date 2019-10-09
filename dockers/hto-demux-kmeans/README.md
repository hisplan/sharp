# hto-demux-kmeans

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hto-demux-kmeans:0.1
```

```bash
$ python3 demux_kmeans.py \
    --hto-umi-count-dir /data/umi_count \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv
```