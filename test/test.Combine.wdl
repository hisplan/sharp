version 1.0

import "modules/Combine.wdl" as module

workflow Combine {

    input {
        File denseCountMatrix
        File htoClassification
        Array[File] umiCountFiles
    }

    call module.HashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoClassification = htoClassification
    }

    output {
        File outClass = HashedCountMatrix.outClass
        File outCountMatrix = HashedCountMatrix.outCountMatrix
        File outStats = HashedCountMatrix.outStats
        File outLog = HashedCountMatrix.outLog
    }
}
