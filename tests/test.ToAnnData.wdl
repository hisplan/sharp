version 1.0

import "modules/ToAnnData.wdl" as module

workflow ToAnnData {

    input {
        String sampleName
        File tagList
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    call module.CiteSeqToAnnData {
        input:
            sampleName = sampleName,
            tagList = tagList,
            umiCountFiles = umiCountFiles,
            readCountFiles = readCountFiles,
            dockerRegistry = dockerRegistry
    }

    output {
        File outAdata = CiteSeqToAnnData.outAdata
        File outLog = CiteSeqToAnnData.outLog
    }
}
