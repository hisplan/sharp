version 1.0

import "modules/AnnData.wdl" as module

workflow AnnData {

    input {
        # common
        String sampleName

        # ToAnnData
        File tagList
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    call module.ToAnnData {
        input:
            sampleName = sampleName,
            tagList = tagList,
            umiCountFiles = umiCountFiles,
            readCountFiles = readCountFiles,
            dockerRegistry = dockerRegistry
    }

    output {
        File outAdata = ToAnnData.outAdata
        File outLog = ToAnnData.outLog
    }
}
