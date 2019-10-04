version 1.0

import "modules/PrepCBWhitelist.wdl" as module

workflow PrepCBWhitelist {

    input {
        File inputFile
        String method
    }

    # *_sparse_counts_barcodes.csv
    if (method == "SeqcSparseCountsBarcodesCsv") {
        call module.WhitelistFromSeqcSparseBarcodes {
            input:
                csvFile = inputFile
        }
    }

    # *_dense.csv
    if (method == "SeqcDenseCountsMatrixCsv") {
        call module.WhitelistFromSeqcDenseMatrix {
            input:
                csvFile = inputFile
        }
    }

    # one barcode per line
    if (method == "BarcodeWhitelistCsv") {
        call module.NotImplemented
    }

    output {
        String out = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out])
    }

}
