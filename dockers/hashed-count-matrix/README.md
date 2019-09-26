# hashed-count-matrix

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hashed-count-matrix:0.1
```

```bash
$ cd /opt
$ python3 correct_fp_doublets.py \
    --hto-classification /data/final-classifiation.tsv \
    --hto-umi-count-dir /data/umi_count \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv
```