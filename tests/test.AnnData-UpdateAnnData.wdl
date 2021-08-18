version 1.0

import "modules/AnnData.wdl" as module

workflow AnnData {

    input {
        # common
        String sampleName

        File htoClassification
        File adata

        # docker-related
        String dockerRegistry
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
        File outAdata = UpdateAnnData.outAdata
        File outLog = UpdateAnnData.outLog
    }
}
