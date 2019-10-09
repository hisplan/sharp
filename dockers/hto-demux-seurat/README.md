# hto-demux-seurat

## Testing

```bash
$ docker run -it --rm \
    -v /Users/chunj/projects/sharp/scratch:/data/ \
    cromwell-hto-demux-seurat:0.3
```

```bash
$ python3 correct_fp_doublets.py \
    --hto-classification /data/test.csv \
    --hto-umi-count-dir /data/umi_count
```
