#!/usr/bin/env python

import sys
import argparse
import pandas as pd
import numpy as np
import yaml
import logging
from dna3bit import DNA3Bit


logger = logging.getLogger("combine")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("combine.log"),
        logging.StreamHandler(sys.stdout)
    ]
)


def combine(path_dense_count_matrix, path_hto_demux_matrix):

    df_gene = pd.read_csv(
        path_dense_count_matrix,
        index_col=0
    )

    logger.info(
        "Loaded transcript count matrix ({} x {})".format(
            df_gene.shape[0], df_gene.shape[1]
        )
    )

    df_hto_demux = pd.read_csv(
        path_hto_demux_matrix,
        sep=",",
        index_col=0
    )

    logger.info(
        "Loaded HTO demux matrix ({} x {})".format(
            df_hto_demux.shape[0], df_hto_demux.shape[1]
        )
    )

    # convert to numeric cell barcode
    dna3bit = DNA3Bit()
    new_index = df_hto_demux.index.map(lambda x: dna3bit.encode(x))
    df_hto_demux.index = new_index

    df_hto_demux.groupby(by="HTO_classification.global").size()

    df_hash = df_hto_demux.loc[:, "hash.ID"].to_frame()
    df_hash.columns = ["hashID"]

    logger.debug(df_hash.groupby(by="hashID").size())

    df_hash.groupby(by="hashID").size() / len(df_hash) * 100.0

    df_hash[df_hash.hashID.isin(
        ["HTO-301", "HTO-302", "HTO-303", "HTO-304"])].shape[0]

    df_hash[df_hash.hashID.isin(
        ["HTO-301", "HTO-302", "HTO-303", "HTO-304"])].shape[0] / len(df_hash) * 100.0

    df_merged = pd.merge(
        df_gene, df_hash,
        left_index=True, right_index=True,
        how="inner"
    )

    logger.info(
        "Merged transcript count matrix with hashtag ({} x {})".format(
            df_merged.shape[0], df_merged.shape[1]
        )
    )

    logger.debug(df_merged.groupby(by="hashID").size())

    logger.info("Writing the full dense count matrix with hashtag...")
    
    df_merged.to_csv(
        "final-matrix.tsv.gz",
        sep="\t",
        compression="gzip"
    )

    # the last column has the hashID
    df_class = df_merged.iloc[:, -1].to_frame()

    df_class.to_csv(
        "final-classification.tsv.gz",
        sep="\t",
        compression="gzip"
    )

    return df_class


def write_stats(df_class):

    stats = df_class.groupby(by="hashID").size().to_dict()
    stats["Total"] = len(df_class)

    with open("stats.yml", "wt") as fout:
        fout.write(yaml.dump(stats))


def parse_arguments():

    # python combine.py --dense-count-matrix 1187_IL10neg_P163_IGO_09902_8_dense.csv --hto-demux-matrix classification.csv

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--dense-count-matrix",
        action="store",
        dest="path_dense_count_matrix",
        help="path to scRNA-seq dnese cell-by-gene count matrix file (*.csv)",
        required=True
    )

    parser.add_argument(
        "--hto-demux-matrix",
        action="store",
        dest="path_hto_demux_matrix",
        help="path to HTO demux matrix file (*.csv)",
        required=True
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    logger.info("Starting...")

    df_class = combine(
        params.path_dense_count_matrix,
        params.path_hto_demux_matrix
    )

    logger.info("Writing statistics...")
    write_stats(df_class)

    logger.info("DONE.")
