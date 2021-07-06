version 1.0

import "modules/HtoDemuxSeurat.wdl" as module

workflow HtoDemuxSeurat {

    input {
        Array[File] umiCountFiles
        Float quantile

        # docker-related
        String dockerRegistry
    }

    call module.HtoDemuxSeurat {
        input:
            umiCountFiles = umiCountFiles,
            quantile = quantile,
            dockerRegistry = dockerRegistry
    }

    call module.CorrectFalsePositiveDoublets {
        input:
            htoClassification = HtoDemuxSeurat.outClassCsv,
            umiCountFiles = umiCountFiles,
            dockerRegistry = dockerRegistry
    }

}
