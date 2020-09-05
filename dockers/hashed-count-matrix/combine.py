#!/usr/bin/env python

import sys
import argparse
import pandas as pd
import numpy as np
import yaml
import csv
import gzip
import logging
from dna3bit import DNA3Bit
from tqdm import tqdm

logger = logging.getLogger("combine")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler("combine.log"), logging.StreamHandler(sys.stdout)],
)


def convert(df, path_10x_whitelist):

    encoder_decoder = DNA3Bit()

    # 1234 barcodes to acgt barcodes
    acgt_barcodes = df.index.map(lambda x: encoder_decoder.decode(x).decode())

    # create a mapper (HTO <--> GEX)
    mapper = dict()

    with gzip.open(path_10x_whitelist, "rt") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter="\t")
        for row in tqdm(csv_reader, disable=None):
            mapper[row[0].strip()] = row[1].strip()

    # translate
    translated_acgt_barcodes = acgt_barcodes.map(lambda x: mapper[x])

    # acgt barcodes to 1234 barcodes
    translated_1234_barcodes = translated_acgt_barcodes.map(
        lambda x: encoder_decoder.encode(x)
    )

    df.index = translated_1234_barcodes

    return df


def combine(
    path_dense_count_matrix,
    path_hto_classification,
    translate_10x_barcodes,
    path_10x_whitelist,
):

    df_gene = pd.read_csv(path_dense_count_matrix, index_col=0)

    logger.info(
        "Loaded transcript count matrix ({} x {})".format(
            df_gene.shape[0], df_gene.shape[1]
        )
    )

    df_class = pd.read_csv(
        path_hto_classification, sep="\t", index_col=0, compression="gzip"
    )

    logger.info(
        "Loaded HTO classification ({} x {})".format(
            df_class.shape[0], df_class.shape[1]
        )
    )

    logger.debug(df_class.groupby(by="hashID").size())

    # translate HTO barcodes to GEX barcodes
    if translate_10x_barcodes:
        logger.info("Translating TotalSeq-B/C HTO barcodes to GEX barcodes...")
        df_class = convert(df_class, path_10x_whitelist)

    df_merged = pd.merge(
        df_gene, df_class, left_index=True, right_index=True, how="inner"
    )

    logger.info(
        "Merged transcript count matrix with hashtag ({} x {})".format(
            df_merged.shape[0], df_merged.shape[1]
        )
    )

    logger.debug(df_merged.groupby(by="hashID").size())

    logger.info("Writing the full dense count matrix with hashtag...")

    df_merged.to_csv("final-matrix.tsv.gz", sep="\t", compression="gzip")

    # the last column has the hashID
    df_class = df_merged.iloc[:, -1].to_frame()

    df_class.to_csv("final-classification.tsv.gz", sep="\t", compression="gzip")

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
        required=True,
    )

    parser.add_argument(
        "--hto-classification",
        action="store",
        dest="path_hto_classification",
        help="path to HTO classification file (*.tsv.gz)",
        required=True,
    )

    parser.add_argument(
        "--10x-barcode-translation",
        action="store_true",
        dest="translate_10x_barcodes",
        help="Translate HTO barcodes to GEX barcodes",
        default=False,
    )

    parser.add_argument(
        "--10x-whitelist",
        action="store",
        dest="path_10x_whitelist",
        help="path to the official 10x barcode whitelist (gzipped)",
        default="data/3M-february-2018.txt.gz",
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    logger.info("Starting...")

    df_class = combine(
        path_dense_count_matrix=params.path_dense_count_matrix,
        path_hto_classification=params.path_hto_classification,
        translate_10x_barcodes=params.translate_10x_barcodes,
        path_10x_whitelist=params.path_10x_whitelist,
    )

    logger.info("Writing statistics...")
    write_stats(df_class)

    logger.info("DONE.")
