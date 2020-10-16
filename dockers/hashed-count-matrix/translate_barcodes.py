#!/usr/bin/env python

import sys
import argparse
import pandas as pd
import numpy as np
import yaml
import csv
import gzip
import logging
from tqdm import tqdm

logger = logging.getLogger("translate_barcodes")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("translate-barcodes.log"),
        logging.StreamHandler(sys.stdout),
    ],
)


def convert(df, path_10x_whitelist):

    # create a mapper (HTO <--> GEX)
    mapper = dict()

    with gzip.open(path_10x_whitelist, "rt") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter="\t")
        for row in tqdm(csv_reader, disable=None):
            mapper[row[0].strip()] = row[1].strip()

    # translate
    translated_barcodes = df.index.map(lambda x: mapper[x])

    df2 = df.copy()
    df2.index = translated_barcodes

    return df2


def translate(
    path_barcodes,
    path_10x_whitelist,
):
    barcodes = pd.read_csv(path_barcodes, sep="\t", index_col=0, header=None, compression="gzip")

    logger.info("Loaded barcodes ({})".format(len(barcodes)))

    # translate HTO barcodes to GEX barcodes
    logger.info("Translating TotalSeq-B/C HTO barcodes to GEX barcodes...")
    df_final = convert(barcodes, path_10x_whitelist)

    df_final.to_csv("barcodes-translated.tsv.gz", header=None, compression="gzip")


def parse_arguments():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--barcodes",
        action="store",
        dest="path_barcodes",
        help="path to barcode file (e.g. 10x's barcodes.tsv.gz)",
        required=True,
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

    translate(
        path_barcodes=params.path_barcodes,
        path_10x_whitelist=params.path_10x_whitelist,
    )

    logger.info("DONE.")
