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

        # UpdateAnnData
        File htoClassification
        File adata

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

    call module.UpdateAnnData {
        input:
            sampleName = sampleName,
            htoClassification = htoClassification,
            translate10XBarcodes = true,
            adata = adata,
            dockerRegistry = dockerRegistry
    }

    output {
        File outAdata = ToAnnData.outAdata
        File outLog = ToAnnData.outLog
    }
}
