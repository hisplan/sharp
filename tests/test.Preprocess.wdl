version 1.0

import "modules/Preprocess.wdl" as module

workflow Preprocess {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2

        Int lengthR1
        Int lengthR2

        String sampleName

        File cellBarcodeWhitelistUri
        String cellBarcodeWhiteListMethod

        # set to false if TotalSeq-A is used
        # set to true if TotalSeq-B or C is used
        Boolean translate10XBarcodes

        String scRnaSeqPlatform = "10x_v3"

        File tagList

        # cellular barcode start/end positions
        Int cbStartPos
        Int cbEndPos

        # UMI start/end positions
        Int umiStartPos
        Int umiEndPos

        # how many bases should we trim before starting to look for hashtag sequence
        Int trimPos = 0

        # activate sliding window alignement
        Boolean slidingWindowSearch = false

        # correction
        Int cbCollapsingDistance
        Int umiCollapsingDistance
        Int maxTagError = 2

        Int numExpectedCells

        Map[String, Int] resourceSpec

        File denseCountMatrix

        Boolean runSeuratDemux = false

        # docker-related
        String dockerRegistry
    }

    call module.Preprocess {
        input:
            uriFastqR1 = uriFastqR1,
            uriFastqR2 = uriFastqR2,
            lengthR1 = lengthR1,
            lengthR2 = lengthR2,
            sampleName = sampleName,
            cellBarcodeWhitelistUri = cellBarcodeWhitelistUri,
            cellBarcodeWhiteListMethod = cellBarcodeWhiteListMethod,
            translate10XBarcodes = translate10XBarcodes,
            scRnaSeqPlatform = scRnaSeqPlatform,
            tagList = tagList,
            cbStartPos = cbStartPos,
            cbEndPos = cbEndPos,
            umiStartPos = umiStartPos,
            umiEndPos = umiEndPos,
            trimPos = trimPos,
            slidingWindowSearch = slidingWindowSearch,
            cbCollapsingDistance = cbCollapsingDistance,
            umiCollapsingDistance = umiCollapsingDistance,
            maxTagError = maxTagError,
            numExpectedCells = numExpectedCells,
            denseCountMatrix = denseCountMatrix,
            runSeuratDemux = runSeuratDemux,
            resourceSpec = resourceSpec,
            dockerRegistry = dockerRegistry
    }
}
