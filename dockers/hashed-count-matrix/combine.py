#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np


class DNA3Bit(object):
    """
    Compact 3-bit encoding scheme for sequence data.
    """

    @staticmethod
    def bits_per_base():
        return 3

# TODO: The sam reader needs to be fixed so text files are read as text not binary
    str2bindict = {65: 0b100, 67: 0b110, 71: 0b101, 84: 0b011, 78: 0b111,
                97: 0b100, 99: 0b110, 103: 0b101, 116: 0b011, 110: 0b111,
                'A': 0b100, 'C': 0b110, 'G': 0b101, 'T': 0b011, 'N': 0b111,
                'a': 0b100, 'c': 0b110, 'g': 0b101, 't': 0b011, 'n': 0b111}
    bin2strdict = {0b100: b'A', 0b110: b'C', 0b101: b'G', 0b011: b'T', 0b111: b'N'}

    @staticmethod
    def encode(b) -> int:
        """
        Convert string nucleotide sequence into binary, note: string is stored so
        that the first nucleotide is in the MSB position

        :param bytes|str b: sequence containing nucleotides to be encoded
        """
        res = 0
        for c in b:
            res <<= 3
            res += DNA3Bit.str2bindict[c]
        return res

    @staticmethod
    def decode(i: int) -> bytes:
        """
        Convert binary nucleotide sequence into string

        :param i: int, encoded sequence to be converted back to nucleotides
        """
        if i < 0:
            message = 'i must be an unsigned (positive) integer, not {0!s}'.format(i)
            raise ValueError(message)
        r = b''
        while i > 0:
            r = DNA3Bit.bin2strdict[i & 0b111] + r
            i >>= 3
        return r

    # TODO: another ooption is to use i.bit_length and take into account preceding 0's
    @staticmethod
    def seq_len(i: int) -> int:
        """
        Return the length of an encoded sequence based on its binary representation

        :param i: int, encoded sequence
        """
        l = 0
        while i > 0:
            l += 1
            i >>= 3
        return l

    @staticmethod
    def contains(s: int, char: int) -> bool:
        """
        return true if the char (bin representation) is contained in seq (binary
        representation)

        :param char: int, encoded character (one must be only one nucleotide)
        :param s: int, sequence of encoded nucleotides
        """
        while s > 0:
            if char == (s & 0b111):
                return True
            s >>= 3
        return False

    @staticmethod
    def ints2int(ints):
        """
        convert an iterable of sequences [i1, i2, i3] into a concatenated single integer
        0bi1i2i3. In cases where the sequence is longer than 64 bits, python will
        transition seamlessly to a long int representation, however the user must be
        aware that downsteam interaction with numpy or other fixed-size representations
        may not function

        :param ints: iterable of encoded sequences to concatenate
        """

        res = 0
        for num in ints:
            tmp = num
            # Get length of next number to concatenate (with enough room for leading 0's)
            while tmp > 0:
                res <<= 3
                tmp >>= 3
            res += num
        return res

    @staticmethod
    def count(seq, char_bin):
        """
        count how many times char is in seq.
        char needs to be an encoded value of one of the bases.
        """
        if char_bin not in DNA3Bit.bin2strdict.keys():
            raise ValueError("DNA3Bit.count was called with an invalid char code - "
                            "{}".format(char_bin))
        res = 0
        while seq > 0:
            if seq & 0b111 == char_bin:
                res += 1
            seq >>= 3
        return res


def main(path_dense_count_matrix, path_hto_demux_matrix, path_hto_demux_unmapped):

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

    df_hash = df_hto_demux.loc[:,"hash.ID"].to_frame()
    df_hash.columns = ["hashID"]

    df_hash.groupby(by="hashID").size()

    df_hash.groupby(by="hashID").size() / len(df_hash) * 100.0

    df_hash[ df_hash.hashID.isin(["HTO-301", "HTO-302", "HTO-303", "HTO-304"]) ].shape[0]

    df_hash[ df_hash.hashID.isin(["HTO-301", "HTO-302", "HTO-303", "HTO-304"]) ].shape[0] / len(df_hash) * 100.0

    df_merged = pd.merge(
        df_gene, df_hash,
        left_index=True, right_index=True,
        how="inner"
    )

    len(df_merged)

    df_merged.groupby(by="hashID").size()

    df_merged.groupby(by="hashID").size() / len(df_merged) * 100.0

    df_merged[ df_merged.hashID.isin(["HTO-301", "HTO-302", "HTO-303", "HTO-304"]) ].shape[0]

    df_merged[ df_merged.hashID.isin(["HTO-301", "HTO-302", "HTO-303", "HTO-304"]) ].shape[0] / len(df_merged) * 100.0

    df_merged.to_csv(
        "final-matrix.tsv",
        sep="\t"
    )

    df_merged.iloc[:,-1].to_frame().to_csv(
        "final-classifiation.tsv",
        sep="\t"
    )


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

    main(
        params.path_dense_count_matrix,
        params.path_hto_demux_matrix,
        params.path_hto_demux_unmapped
    )
