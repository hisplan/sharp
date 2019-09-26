# hashed-count-matrix

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hashed-count-matrix:0.1
```

```bash
$ python3 combine.py \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv \
    --hto-demux-matrix /data/classification.csv
```

```bash
$ cd /opt
$ python3 correct_fp_doublets.py \
    --hto-classification /data/final-classifiation.tsv.gz \
    --hto-umi-count-dir /data/umi_count \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv
```
