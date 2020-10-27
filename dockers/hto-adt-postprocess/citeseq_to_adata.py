#!/usr/bin/env python
# coding: utf-8

import sys
import os
import argparse
import logging

import scanpy as sc
import pandas as pd
import numpy as np
import scipy.io

from dna3bit import DNA3Bit

numba_logger = logging.getLogger("numba")
numba_logger.setLevel(logging.WARNING)

logger = logging.getLogger("citeseq_to_adata")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("citeseq_to_adata.log"),
        logging.StreamHandler(sys.stdout),
    ],
)


def to_adata(sample_name, path_tag_list, path_umi_counts, path_read_counts):

    logger.info("Loading antibody tag list...")
    df_tags = pd.read_csv(
        path_tag_list, header=None, names=["seq", "id", "antibody", "shift"]
    )

    df_tags.index = (df_tags.id + "-" + df_tags.seq).values

    logger.info("Loading counts matrix...")
    mtx_umi = scipy.io.mmread(os.path.join(path_umi_counts, "matrix.mtx.gz"))

    barcodes = pd.read_csv(
        os.path.join(path_umi_counts, "barcodes.tsv.gz"), header=None, index_col=0
    )
    barcodes.index.name = "cell_barcodes"

    features = pd.read_csv(
        os.path.join(path_umi_counts, "features.tsv.gz"), header=None, index_col=0
    )
    features.index.name = None

    logger.info("Generating AnnData...")
    # convert to AnnData
    # exclude `unmapped` column
    adata = sc.AnnData(mtx_umi.T.tocsr()[:, :-1], obs=barcodes, var=features.iloc[:-1])

    adata.obs["unmapped"] = mtx_umi.T.toarray()[:, -1]

    antibody_names = adata.var.index.map(lambda x: df_tags.loc[x, "antibody"])

    dna3bit = DNA3Bit()

    numerical_barcodes = adata.obs.index.map(lambda x: str(dna3bit.encode(x)))

    # add barcode sequence
    adata.obs["barcode_sequence"] = adata.obs_names

    # use numerical barcodes for the main obs names
    adata.obs_names = numerical_barcodes

    sc.pp.calculate_qc_metrics(
        adata, percent_top=(5, 10, 15), var_type="antibodies", inplace=True
    )

    adata.write(sample_name + ".CITE-seq.h5ad")


def parse_arguments():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--sample",
        action="store",
        dest="sample_name",
        help="sample name (e.g. 2091_CS1429a_T_1_CD45pos_citeseq_2_CITE)",
        required=True,
    )

    parser.add_argument(
        "--tag-list",
        action="store",
        dest="path_tag_list",
        help="path to tag list file (e.g. tag-list.csv0",
        required=True,
    )

    parser.add_argument(
        "--umi-counts",
        action="store",
        dest="path_umi_counts",
        help="path to umi counts (e.g. umi-counts/)",
        required=True,
    )

    parser.add_argument(
        "--read-counts",
        action="store",
        dest="path_read_counts",
        help="path to read counts (e.g. read-counts/)",
        required=True,
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    logger.info("Starting...")

    to_adata(
        sample_name=params.sample_name,
        path_tag_list=params.path_tag_list,
        path_umi_counts=params.path_umi_counts,
        path_read_counts=params.path_read_counts,
    )

    logger.info("DONE.")
