version 1.0

import "modules/Combine.wdl" as module

workflow Combine {

    input {
        File denseCountMatrix
        File htoClassification
        Boolean translate10XBarcodes
    }

    call module.HashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoClassification = htoClassification,
            translate10XBarcodes = translate10XBarcodes
    }

    output {
        File outClass = HashedCountMatrix.outClass
        File outCountMatrix = HashedCountMatrix.outCountMatrix
        File outStats = HashedCountMatrix.outStats
        File outLog = HashedCountMatrix.outLog
    }
}
