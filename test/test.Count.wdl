version 1.0

import "modules/Count.wdl" as module

workflow Count {

    input {
        File fastqR1
        File fastqR2
        File cbWhiteList
        File tagList

        # cellular barcode
        Int cbStartPos
        Int cbEndPos

        # UMI
        Int umiStartPos
        Int umiEndPos

        # how many bases should we trim before starting to look for hashtag sequence
        Int trimPos

        # activate sliding window alignement
        Boolean slidingWindowSearch

        Int cbCollapsingDistance
        Int umiCollapsingDistance
        Int maxTagError

        Int numExpectedCells

        Map[String, Int] resourceSpec

        String version
    }

    call module.CiteSeqCount {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            cbWhiteList = cbWhiteList,
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
            resourceSpec = resourceSpec,
            version = version
    }

    output {
        File outReport = CiteSeqCount.outReport
        File? outUnmapped = CiteSeqCount.outUnmapped
        File? outUncorrected = CiteSeqCount.outUncorrected

        Array[File] outUmiCount = CiteSeqCount.outUmiCount
        Array[File] outReadCount = CiteSeqCount.outReadCount
    }
}
