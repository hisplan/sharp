# hto-adt-postprocess

## Testing

```bash
$ docker run -it --rm \
    -v $(pwd)/tests/citeseq:/tests \
    cromwell-hto-adt-postprocess:0.3.3
```

### combine.py

```bash
python3 combine.py \
    --dense-count-matrix /data/1187_IL10neg_P163_IGO_09902_8_dense.csv \
    --hto-classification /data/final-classification.tsv.gz
```

### to_adata.py

```bash
python3 to_adata.py \
    --sample test \
    --tag-list /tests/tag-list.csv \
    --umi-counts /tests/umi-counts/ \
    --read-counts /tests/read-counts/
```
