version 1.0

import "modules/Preprocess.wdl" as Preprocess
import "modules/HtoDemuxSeurat.wdl" as HtoDemuxSeurat
import "modules/HtoDemuxKMeans.wdl" as HtoDemuxKMeans
import "modules/ReformatFastq.wdl" as ReformatFastq
import "modules/AnnData.wdl" as AnnData

workflow AsapSeq {

    input {
        Array[File] fastqR1
        Array[File] fastqR2
        Array[File] fastqR3

        String conjugation = "TotalSeqA"
        Boolean noReverseComplementR2 = false

        Int lengthR1
        Int lengthR2

        String sampleName

        File cellBarcodeWhitelistUri
        String cellBarcodeWhiteListMethod

        Boolean translate10XBarcodes

        String scRnaSeqPlatform = "10x_v3"

        File hashTagList

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

        Boolean runSeuratDemux = false
        Int demuxMode = 1
        Int minCount = 0

        Map[String, Int] resourceSpec

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        demuxMode: { help: "1=default, 2=noisy methanol, 3=aggressively rescue from doublets" }
    }

    call ReformatFastq.ReformatAsapSeqFastq {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            fastqR3 = fastqR3,
            sampleName = sampleName,
            conjugation = conjugation,
            noReverseComplementR2 = noReverseComplementR2,
            numCores = 4,
            dockerRegistry = dockerRegistry
    }

    call Preprocess.Preprocess {
        input:
            uriFastqR1 = [ReformatAsapSeqFastq.outFastqR1],
            uriFastqR2 = [ReformatAsapSeqFastq.outFastqR2],
            lengthR1 = lengthR1,
            lengthR2 = lengthR2,
            sampleName = sampleName,
            cellBarcodeWhitelistUri = cellBarcodeWhitelistUri,
            cellBarcodeWhiteListMethod = cellBarcodeWhiteListMethod,
            translate10XBarcodes = translate10XBarcodes,
            scRnaSeqPlatform = scRnaSeqPlatform,
            tagList = hashTagList,
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
            dockerRegistry = dockerRegistry
    }

    # HTO demux using KMeans
    call HtoDemuxKMeans.HtoDemuxKMeans {
        input:
            umiCountFiles = Preprocess.umiCountMatrix,
            minCount = minCount,
            mode = demuxMode,
            dockerRegistry = dockerRegistry
    }

    # HTO demux using Seurat
    if (runSeuratDemux == true) {

        call HtoDemuxSeurat.HtoDemuxSeurat {
            input:
                umiCountFiles = Preprocess.umiCountMatrix,
                quantile = 0.99,
                dockerRegistry = dockerRegistry
        }

        # correct false positive doublets frm Seurat output
        call HtoDemuxSeurat.CorrectFalsePositiveDoublets {
            input:
                htoClassification = HtoDemuxSeurat.outClassCsv,
                umiCountFiles = Preprocess.umiCountMatrix,
                dockerRegistry = dockerRegistry
        }
    }

    call AnnData.UpdateAnnData {
        input:
            sampleName = sampleName,
            htoClassification = HtoDemuxKMeans.outClass,
            translate10XBarcodes = translate10XBarcodes,
            adata = Preprocess.adata,
            dockerRegistry = dockerRegistry
    }

    output {
        File reformattedR1 = ReformatAsapSeqFastq.outFastqR1
        File reformattedR2 = ReformatAsapSeqFastq.outFastqR2

        File fastQCR1Html = Preprocess.fastQCR1Html
        File fastQCR2Html = Preprocess.fastQCR2Html

        File countReport = Preprocess.countReport
        Array[File] umiCountMatrix = Preprocess.umiCountMatrix
        Array[File] readCountMatrix = Preprocess.readCountMatrix

        File htoClassification = HtoDemuxKMeans.outClass
        File? htoClassification_Suppl1 = HtoDemuxSeurat.outClassCsv
        File? htoClassification_Suppl2 = HtoDemuxSeurat.outFullCsv
        File? htoClassification_Suppl3 = CorrectFalsePositiveDoublets.outClass

        File statsHtoDemux = HtoDemuxKMeans.outStats
        File? statsHtoDemux_Suppl1 = CorrectFalsePositiveDoublets.outStats

        File logHtoDemux = HtoDemuxKMeans.outLog
        File? logHtoDemux_Suppl1 = CorrectFalsePositiveDoublets.outLog

        File adataRaw = Preprocess.adata
        File adataFinal = UpdateAnnData.outAdata
    }
}
