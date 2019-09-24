version 1.0

import "modules/Count.wdl" as modules

workflow Count {

    input {
        File fastqR1
        File fastqR2
        File cbWhiteList
        File hashTagList

        # cellular barcode
        Int cbStartPos
        Int cbEndPos

        # UMI
        Int umiStartPos
        Int umiEndPos

        Int cbCollapsingDistance
        Int umiCollapsingDistance

        Int numExpectedCells
    }

    call modules.RunCiteSeqCount {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            cbWhiteList = cbWhiteList,
            hashTagList = hashTagList,
            cbStartPos = cbStartPos,
            cbEndPos = cbEndPos,
            umiStartPos = umiStartPos,
            umiEndPos = umiEndPos,
            cbCollapsingDistance = cbCollapsingDistance,
            umiCollapsingDistance = umiCollapsingDistance,
            numExpectedCells = numExpectedCells
    }

    output {
        File outUmiDenseCount = RunCiteSeqCount.outUmiDenseCount
        File outUnmapped = RunCiteSeqCount.outUnmapped
        File outReport = RunCiteSeqCount.outReport
        File outUncorrected = RunCiteSeqCount.outUncorrected

        Array[File] outUmiCount = RunCiteSeqCount.outUmiCount
        Array[File] outReadCount = RunCiteSeqCount.outReadCount
    }
}
