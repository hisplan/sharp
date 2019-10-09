version 1.0

import "modules/HtoDemuxSeurat.wdl" as module

workflow HtoDemuxSeurat {

    input {
        Array[File] umiCountFiles
        Float quantile
    }

    call module.HtoDemuxSeurat {
        input:
            umiCountFiles = umiCountFiles,
            quantile = quantile
    }
}
