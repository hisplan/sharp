#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np
import yaml
from dna3bit import DNA3Bit


def combine(path_dense_count_matrix, path_hto_demux_matrix, path_hto_demux_unmapped):

    df_unmapped = pd.read_csv(
        path_hto_demux_unmapped,
        index_col=0
    )

    df_unmapped["count"].sum()

    df_gene = pd.read_csv(
        path_dense_count_matrix,
        index_col=0
    )

    df_gene.shape

    dna3bit = DNA3Bit()

    df_hto_demux = pd.read_csv(
        path_hto_demux_matrix,
        sep=",",
        index_col=0
    )

    new_index = df_hto_demux.index.map(lambda x: dna3bit.encode(x))

    df_hto_demux.index = new_index

    df_hto_demux.groupby(by="HTO_classification.global").size()

    df_hash = df_hto_demux.loc[:, "hash.ID"].to_frame()
    df_hash.columns = ["hashID"]

    print(df_hash.groupby(by="hashID").size())

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

    len(df_merged)

    print(df_merged.groupby(by="hashID").size())

    df_merged.groupby(by="hashID").size() / len(df_merged) * 100.0

    df_merged[df_merged.hashID.isin(
        ["HTO-301", "HTO-302", "HTO-303", "HTO-304"])].shape[0]

    df_merged[df_merged.hashID.isin(
        ["HTO-301", "HTO-302", "HTO-303", "HTO-304"])].shape[0] / len(df_merged) * 100.0

    df_merged.to_csv(
        "final-matrix.tsv.gz",
        sep="\t",
        compression="gzip"
    )

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

    # python combine.py --dense-count-matrix 1187_IL10neg_P163_IGO_09902_8_dense.csv --hto-demux-matrix classification.csv --hto-demux-unmapped IL10neg_HTO.unmapped.csv

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

    parser.add_argument(
        "--hto-demux-unmapped",
        action="store",
        dest="path_hto_demux_unmapped",
        help="path to HTO demux unmapped file (*.csv)",
        required=True
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    df_class = combine(
        params.path_dense_count_matrix,
        params.path_hto_demux_matrix,
        params.path_hto_demux_unmapped
    )

    write_stats(df_class)
