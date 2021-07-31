# hto-adt-postprocess

## Unit Tests

```bash
pytest -v
```

```
==================================== test session starts ====================================
platform darwin -- Python 3.7.7, pytest-6.2.4, py-1.10.0, pluggy-0.13.1 -- /Users/chunj/opt/miniconda3/envs/sharp/bin/python
cachedir: .pytest_cache
rootdir: /Users/chunj/projects/sharp, configfile: pytest.ini, testpaths: dockers/hto-adt-postprocess/
collected 3 items

dockers/hto-adt-postprocess/test_modules.py::test_hto_gex_mapper_create PASSED        [ 33%]
dockers/hto-adt-postprocess/test_modules.py::test_hto_gex_translation_1 PASSED        [ 66%]
dockers/hto-adt-postprocess/test_modules.py::test_hto_gex_translation_2 PASSED        [100%]

==================================== 3 passed in 19.23s =====================================
```

## Run

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
