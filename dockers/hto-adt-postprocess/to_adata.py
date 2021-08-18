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

logger = logging.getLogger("to_adata")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("to_adata.log"),
        logging.StreamHandler(sys.stdout),
    ],
)


def to_adata(sample_name, path_tag_list, path_umi_counts, path_read_counts):

    sc.logging.print_header()

    logger.info("Loading tag list...")
    df_tags = pd.read_csv(
        path_tag_list, header=None, names=["seq", "id", "feature_name", "shift"]
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
    adata = sc.AnnData(
        mtx_umi.T.tocsr()[:, :-1], dtype="int64", obs=barcodes, var=features.iloc[:-1]
    )

    # add unmapped to obs
    adata.obs["unmapped"] = mtx_umi.T.toarray()[:, -1]

    # add human-friendly feature name to var
    # sample of origin in case of hashtag, antibody name in case of CITE-seq
    # stringify at the end (some antibody name is composed of just numbers)
    feature_names = adata.var.index.map(lambda x: str(df_tags.loc[x, "feature_name"]))
    adata.var["feature_name"] = feature_names

    dna3bit = DNA3Bit()
    # get numerical barcodes but stringify (not allowed to store numbers in obs.index)
    numerical_barcodes = adata.obs.index.map(lambda x: str(dna3bit.encode(x)))
    # add nucleotide barcode to obs
    adata.obs["barcode_sequence"] = adata.obs_names

    # use numerical barcodes for obs index
    adata.obs_names = numerical_barcodes

    adata.write(sample_name + ".h5ad")


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
        help="path to tag list file (e.g. tag-list.csv)",
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
