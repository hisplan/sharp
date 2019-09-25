version 1.0

import "modules/HtoDemux.wdl" as module

workflow HtoDemux {

    input {
        Array[File] umiCountFiles
        Float quantile
    }

    call module.HtoDemux {
        input:
            umiCountFiles = umiCountFiles,
            quantile = quantile
    }
}
