version 1.0

import "modules/PrepCBWhitelist.wdl" as module

workflow PrepCBWhitelist {

    input {
        File inputFile
        String method

        # docker-related
        String dockerRegistry
    }

    # *_sparse_counts_barcodes.csv
    if (method == "SeqcSparseCountsBarcodesCsv") {
        call module.WhitelistFromSeqcSparseBarcodes {
            input:
                csvFile = inputFile,
                dockerRegistry = dockerRegistry
        }
    }

    # *_dense.csv
    if (method == "SeqcDenseCountsMatrixCsv") {
        call module.WhitelistFromSeqcDenseMatrix {
            input:
                csvFile = inputFile,
                dockerRegistry = dockerRegistry
        }
    }

    # one barcode per line
    if (method == "BarcodeWhitelistCsv") {
        call module.NotImplemented
    }

    File whitelist = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out])

    call module.Translate10XBarcodes {
        input:
            barcodesFile = whitelist,
            dockerRegistry = dockerRegistry
    }

    output {
        String outTranslated = Translate10XBarcodes.out
    }

}
