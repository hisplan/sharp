import pytest
import os
import pandas as pd

import translate_barcodes
import hto_gex_mapper


@pytest.fixture
def setup_path():

    path_data = "dockers/hto-adt-postprocess/data"
    path_test_data = "dockers/hto-adt-postprocess/tests"
    yield path_data, path_test_data


def test_hto_gex_mapper_create(setup_path):

    path_data, path_test_data = setup_path

    # $ gunzip -c 3M-february-2018.txt.gz | grep "AAATGGATCGTCGTGA"
    # AAATGGAAGGTCGTGA	AAATGGATCGTCGTGA
    # AAATGGATCGTCGTGA	AAATGGAAGGTCGTGA

    # $ gunzip -c 3M-february-2018.txt.gz | grep "AAATGGATCGTCTTTG"
    # AAATGGAAGGTCTTTG	AAATGGATCGTCTTTG
    # AAATGGATCGTCTTTG	AAATGGAAGGTCTTTG

    # $ gunzip -c 3M-february-2018.txt.gz | grep "TTTGTTGAGTTTCTTC"
    # TTTGTTGAGTTTCTTC	TTTGTTGTCTTTCTTC
    # TTTGTTGTCTTTCTTC	TTTGTTGAGTTTCTTC

    mapper = hto_gex_mapper.create(
        path_10x_whitelist=os.path.join(path_data, "3M-february-2018.txt.gz")
    )

    assert mapper["AAATGGAAGGTCGTGA"] == "AAATGGATCGTCGTGA"
    assert mapper["AAATGGATCGTCTTTG"] == "AAATGGAAGGTCTTTG"
    assert mapper["TTTGTTGAGTTTCTTC"] == "TTTGTTGTCTTTCTTC"


def test_hto_gex_translation_1(setup_path):

    path_data, path_test_data = setup_path

    # $ gunzip -c 3M-february-2018.txt.gz | grep "AAATGGATCGTCGTGA"
    # AAATGGAAGGTCGTGA	AAATGGATCGTCGTGA
    # AAATGGATCGTCGTGA	AAATGGAAGGTCGTGA

    # $ gunzip -c 3M-february-2018.txt.gz | grep "AAATGGATCGTCTTTG"
    # AAATGGAAGGTCTTTG	AAATGGATCGTCTTTG
    # AAATGGATCGTCTTTG	AAATGGAAGGTCTTTG

    barcodes = ["AAATGGAAGGTCGTGA", "AAATGGATCGTCTTTG"]
    df = pd.DataFrame(barcodes).set_index(0)

    translated = translate_barcodes.convert(
        df=df,
        path_hto_gex_mapper=os.path.join(path_data, "10x-hto-gex-mapper.pickle"),
    )

    assert translated.iloc[0].name == "AAATGGATCGTCGTGA"
    assert translated.iloc[1].name == "AAATGGAAGGTCTTTG"


def test_hto_gex_translation_2(setup_path):

    path_data, path_test_data = setup_path

    # $ gunzip -c 3M-february-2018.txt.gz | grep "GCGAGAAGTAGACCGA"
    # GCGAGAACAAGACCGA	GCGAGAAGTAGACCGA
    # GCGAGAAGTAGACCGA	GCGAGAACAAGACCGA

    barcodes = pd.read_csv(
        os.path.join(path_test_data, "barcodes.tsv.gz"),
        sep="\t",
        index_col=0,
        header=None,
        compression="gzip",
    )

    translated = translate_barcodes.convert(
        df=barcodes,
        path_hto_gex_mapper=os.path.join(path_data, "10x-hto-gex-mapper.pickle"),
    )

    for i, barcode in enumerate(barcodes.index):
        if barcode == "GCGAGAAGTAGACCGA":
            assert translated.iloc[i].name == "GCGAGAACAAGACCGA"
            return

    raise Exception("The test file doesn't include the barcode you're testing...")
