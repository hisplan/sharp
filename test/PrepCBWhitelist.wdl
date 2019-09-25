version 1.0

import "modules/PrepCBWhitelist.wdl" as modules

workflow PrepCBWhitelist {

    input {
        File inputFile
        String method
    }

    # *_sparse_counts_barcodes.csv
    if (method == "SeqcSparseCountsBarcodesCsv") {
        call modules.WhitelistFromSeqcSparseBarcodes {
            input:
                csvFile = inputFile
        }
    }

    # *_dense.csv
    if (method == "SeqcDenseCountsMatrixCsv") {
        call modules.WhitelistFromSeqcDenseMatrix {
            input:
                csvFile = inputFile
        }
    }

    # one barcode per line
    if (method == "BarcodeWhitelistCsv") {
        call modules.NotImplemented
    }

    output {
        String out = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out])
    }

}
