#!/usr/bin/env python
# coding: utf-8

import os
import argparse
import pandas as pd
import numpy as np
import scipy.io
import scipy.stats
from sklearn.cluster import KMeans


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
    bin2strdict = {0b100: b'A', 0b110: b'C',
                   0b101: b'G', 0b011: b'T', 0b111: b'N'}

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
            message = 'i must be an unsigned (positive) integer, not {0!s}'.format(
                i)
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


def main(path_dense_count_matrix, path_hto_classification, path_hto_umi_count_dir):

    # index = numeric cellular barcode (e.g. 120703409573286, ...)
    # column = hashID (e.g. HTO-301, Doublet, ...)
    df_class = pd.read_csv(
        path_hto_classification,
        index_col=0,
        sep="\t"
    )

    matrix = scipy.io.mmread(
        os.path.join(path_hto_umi_count_dir, "matrix.mtx.gz")
    )
    barcodes = pd.read_csv(
        os.path.join(path_hto_umi_count_dir, "barcodes.tsv.gz"),
        header=None
    )[0]
    features = pd.read_csv(
        os.path.join(path_hto_umi_count_dir, "features.tsv.gz"),
        header=None
    )[0]

    dna3bit = DNA3Bit()

    numeric_barcodes = barcodes.apply(lambda cb: dna3bit.encode(cb))

    df_umi = pd.DataFrame(
        matrix.todense(),
        columns=numeric_barcodes,
        index=features
    ).T

    # index = numeric cellular barcode (e.g. 120703409573286, ...)
    # column 1 = hashID (e.g. HTO-301, Doublet, ...)
    # column 2 = (e.g. HTO_301-ACCCACCAGTAAGAC)
    # column 3 = HTO_302-GGTCGAGAGCATTCA
    # column 4 = HTO_303-CTTGCCGCATGTCAT
    # column 5 = HTO_304-AAAGCATTCTTCACG
    # column 6 = unmapped
    df_doublets_umi = pd.merge(
        df_class[df_class.hashID == "Doublet"], df_umi,
        left_index=True, right_index=True,
        how="inner"
    )

    # remove the column `unmapped`
    df_fp = df_doublets_umi.iloc[:, 1:5]

    # centered log-ratio (CLR) transformation
    #     	            HTO_301-ACCCACCAGTAAGAC	HTO_302-GGTCGAGAGCATTCA	HTO_303-CTTGCCGCATGTCAT	HTO_304-AAAGCATTCTTCACG
    # 227929296066909	2.609550	0.076485	2.049975	0.137688
    # 164640656084404	2.477301	0.054396	0.046804	3.561632
    # 121748877338358	2.501004	0.091309	0.034176	3.327706
    # 134463437596589	3.060824	2.458869	0.053883
    df_clr = df_fp.apply(lambda row: np.log1p(
        (row + 1) / scipy.stats.mstats.gmean(row + 1)), axis=1)

    # change column name to column index so that we can access by e.g. x[1]
    df_tmp = df_doublets_umi.iloc[:, 1:5]
    df_tmp.columns = range(0, 4)

    # for each row (barcode), get the index of the one with the largest UMI count
    ss_doublets_umi_largest = df_tmp.idxmax(axis=1)

    def kemans_per_row(row):
        x = np.array(row).reshape(-1, 1)
        kmeans = KMeans(n_clusters=2, random_state=0).fit(x)
        y_predict = kmeans.predict(x)
        return y_predict

    # 227922838763364    [0, 1, 1, 1]
    # 239596337850148    [0, 0, 1, 0]
    # 164759051090203    [0, 1, 1, 1]
    # 191020391422693    [0, 1, 1, 0]
    # 204968413023541    [0, 0, 0, 1]
    df_kmeans = df_clr.apply(lambda row: kemans_per_row(row), axis=1)

    df_kmeans_hotencoded = df_kmeans.apply(
        lambda x: "".join(str(y) for y in x)).to_frame()

    # shorten and replace _ with -
    # ['HTO-301', 'HTO-302', 'HTO-303', 'HTO-304']
    hto_names = list(map(lambda name: name.split(
        "-")[0].replace("_", "-"), df_clr.columns))

    def demux_pass2(cb):

        # index of hto having the largest UMIs: 0, 1, 2, or 3
        idmax = ss_doublets_umi_largest[cb]

        # which group belongs to? 0 or 1
        group_id = df_kmeans_hotencoded.loc[cb][0][idmax]

        # how many hto belong that group?
        num_htos = df_kmeans_hotencoded.loc[cb][0].count(group_id)

        # if greater than or equal to two HTOs belong to that group, it means doublet
        # return "Doublet" if doublet, return HTO ID if singlet
        # return "Doublet" if num_htos >= 2 else "Singlet"
        return "Doublet" if num_htos >= 2 else hto_names[idmax]

    df_pass2 = pd.concat([df_doublets_umi, df_kmeans_hotencoded], axis=1)

    # add `rescue` column which shows post-FP-corrected hash ID
    df_pass2 = df_pass2.assign(
        rescue=df_kmeans_hotencoded.index.map(lambda cb: demux_pass2(cb)))

    df_pass2.groupby("rescue").size()

    df_pass2[df_pass2.rescue != "Doublet"]

    fp_corrected = df_pass2.rescue.to_dict()

    # update the originla classification table
    # with the FP corrected
    new_class = df_class.index.map(
        lambda cb: fp_corrected[cb] if cb in fp_corrected else df_class.loc[cb].values[0]
    )
    df_class.hashID = new_class

    print(df_class.groupby(by="hashID").size())

    df_class.to_csv(
        "final-classification.tsv",
        sep="\t"
    )

    df_gene = pd.read_csv(
        path_dense_count_matrix,
        index_col=0
    )

    df_merged = pd.merge(
        df_gene, df_class,
        left_index=True, right_index=True,
        how="inner"
    )

    df_merged.to_csv(
        "final-matrix.tsv",
        sep="\t"
    )


def parse_arguments():

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--dense-count-matrix",
        action="store",
        dest="path_dense_count_matrix",
        help="path to scRNA-seq dnese cell-by-gene count matrix file (*.csv)",
        required=True
    )

    parser.add_argument(
        "--hto-classification",
        action="store",
        dest="path_hto_classification",
        help="path to HTO demux matrix file (*.csv)",
        required=True
    )

    parser.add_argument(
        "--hto-umi-count-dir",
        action="store",
        dest="path_hto_umi_count_dir",
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
        params.path_hto_classification,
        params.path_hto_umi_count_dir
    )
