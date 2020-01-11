#!/usr/bin/env python

import sys
import gzip
import argparse
import logging
from Bio import SeqIO


logger = logging.getLogger("cut_indrop_spacer")

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("cut.log"),
        logging.StreamHandler(sys.stdout)
    ]
)


def cut_indrop_spacer(path_in, path_out, assay_version):

    #fixme: support different assay version

    if assay_version == "in_drop_v4":
        with gzip.open(path_in, "rt") as fin:
            with gzip.open(path_out, "wt") as fout:
                for record in SeqIO.parse(fin, "fastq"):
                    trimmed_rec = record[:8] + record[12:20] + record[20:28]
                    SeqIO.write(trimmed_rec, fout, "fastq")
    else:
        raise Exception("Unsupported assay version!")


def parse_arguments():

    # python cut.py --fastq 1687_LX33_1_4_1_HTO_IGO_10298_C_1_S1_R1_001.fastq.gz

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--in",
        action="store",
        dest="path_in",
        help="path to gzipped input FASTQ",
        required=True
    )

    parser.add_argument(
        "--out",
        action="store",
        dest="path_out",
        help="path to gzipped output FASTQ",
        required=True
    )

    parser.add_argument(
        "--assay-version",
        action="store",
        dest="assay_version",
        help="InDrops assay version",
        required=True
    )

    # parse arguments
    params = parser.parse_args()

    return params


if __name__ == "__main__":

    params = parse_arguments()

    logger.info("Starting...")

    cut_indrop_spacer(
        params.path_in, params.path_out,
        params.assay_version
    )

    logger.info("DONE.")
