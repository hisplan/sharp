version 1.0

import "modules/Combine.wdl" as module

workflow Combine {

    input {
        File denseCountMatrix
        File htoDemuxMatrix
        Array[File] umiCountFiles
    }

    call module.HashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoDemuxMatrix = htoDemuxMatrix
    }

    call module.CorrectFalsePositiveDoublets {
        input:
            htoClassification = HashedCountMatrix.outClass,
            denseCountMatrix = denseCountMatrix,
            umiCountFiles = umiCountFiles
    }

    output {
        File outClass = HashedCountMatrix.outClass
        File outCountMatrix = HashedCountMatrix.outCountMatrix
        File outStats = HashedCountMatrix.outStats
        File outLog = HashedCountMatrix.outLog

        File outCorrectedClass = CorrectFalsePositiveDoublets.outClass
        File outCorrectedCountMatrix = CorrectFalsePositiveDoublets.outCountMatrix
        File outCorrectedStats = CorrectFalsePositiveDoublets.outStats
        File outCorrectedLog = CorrectFalsePositiveDoublets.outLog
    }
}
