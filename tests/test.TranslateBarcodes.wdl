version 1.0

import "modules/TranslateBarcodes.wdl" as module

workflow TranslateBarcodes {

    input {
        Array[File] umiCountFiles
        Array[File] readCountFiles
    }


    call module.Translate10XBarcodes {
        input:
            umiCountFiles = umiCountFiles,
            readCountFiles = readCountFiles
    }
}
