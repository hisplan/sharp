version 1.0

import "modules/HtoDemuxKMeans.wdl" as module

workflow HtoDemuxKMeans {

    input {
        Array[File] umiCountFiles

        # docker-related
        String dockerRegistry
    }

    call module.HtoDemuxKMeans {
        input:
            umiCountFiles = umiCountFiles,
            dockerRegistry = dockerRegistry
    }

    output {
        File outClass = HtoDemuxKMeans.outClass
        File outStats = HtoDemuxKMeans.outStats
        File outLog = HtoDemuxKMeans.outLog
    }
}
