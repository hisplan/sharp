version 1.0

import "modules/HtoDemuxKMeans.wdl" as module

workflow HtoDemuxKMeans {

    input {
        Array[File] umiCountFiles
        Int minCount=0
        Int mode=1

        # docker-related
        String dockerRegistry
    }

    call module.HtoDemuxKMeans {
        input:
            umiCountFiles = umiCountFiles,
            minCount = minCount,
            mode = mode,            
            dockerRegistry = dockerRegistry
    }

    output {
        File outClass = HtoDemuxKMeans.outClass
        File outStats = HtoDemuxKMeans.outStats
        File outLog = HtoDemuxKMeans.outLog
    }
}
