version 1.0

import "modules/TranslateBarcodes.wdl" as module

workflow TranslateBarcodes {

    input {
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    call module.Translate10XBarcodes {
        input:
            umiCountFiles = umiCountFiles,
            readCountFiles = readCountFiles,
            dockerRegistry = dockerRegistry
    }
}
