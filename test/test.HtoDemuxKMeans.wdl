version 1.0

import "modules/HtoDemuxKMeans.wdl" as module

workflow HtoDemuxKMeans {

    input {
        File denseCountMatrix
        Array[File] umiCountFiles
    }

    call module.HtoDemuxKMeans {
        input:
            denseCountMatrix = denseCountMatrix,
            umiCountFiles = umiCountFiles
    }

    output {
        File outClass = HtoDemuxKMeans.outClass
        File outCountMatrix = HtoDemuxKMeans.outCountMatrix
        File outStats = HtoDemuxKMeans.outStats
        File outLog = HtoDemuxKMeans.outLog
    }
}
