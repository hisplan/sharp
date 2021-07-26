import os
import csv
import gzip
import pickle
from tqdm import tqdm

default_path_mapper = "./data/10x-hto-gex-mapper.pickle"


def create(path_10x_whitelist: str) -> dict:

    # create a mapper (TotalSeq-B/C HTO <--> GEX mapper)
    mapper = dict()

    with gzip.open(path_10x_whitelist, "rt") as csv_file:
        csv_reader = csv.reader(csv_file, delimiter="\t")
        for row in tqdm(csv_reader, disable=None):
            mapper[row[0].strip()] = row[1].strip()

    return mapper


def write(mapper: dict):

    with open(default_path_mapper, "wb") as fout:
        pickle.dump(mapper, fout)


def load(path_mapper: str = default_path_mapper) -> dict:

    with open(path_mapper, "rb") as fin:
        mapper = pickle.load(fin)

    return mapper


def exists(path_mapper: str = default_path_mapper) -> bool:

    return os.path.exists(path_mapper)


if __name__ == "__main__":

    mapper = create("./data/3M-february-2018.txt.gz")

    write(mapper)

    print("DONE.")
