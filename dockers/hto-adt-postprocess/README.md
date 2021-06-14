# hto-adt-postprocess

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hto-adt-postprocess:0.3.1
```

```bash
$ python3 combine.py \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv \
    --hto-classification /data/final-classification.tsv.gz
```
