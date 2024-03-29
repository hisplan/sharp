version 1.0

import "modules/Preprocess.wdl" as Preprocess
import "modules/HtoDemuxSeurat.wdl" as HtoDemuxSeurat
import "modules/HtoDemuxKMeans.wdl" as HtoDemuxKMeans
import "modules/Combine.wdl" as Combine
import "modules/AnnData.wdl" as AnnData
import "modules/BasicQC.wdl" as BasicQC

workflow Hashtag {

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

        File? denseCountMatrix

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

    call Preprocess.Preprocess {
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

    # combine count matrix with hashtag classification
    # if SEQC dense count matrix is provided
    if (defined(denseCountMatrix)) {
        call Combine.HashedCountMatrix {
            input:
                denseCountMatrix = select_first([denseCountMatrix]),
                htoClassification = HtoDemuxKMeans.outClass,
                translate10XBarcodes = translate10XBarcodes,
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

    call BasicQC.BasicQC {
        input:
            sampleName = sampleName,
            h5ad = UpdateAnnData.outAdata,
            readsCount = Preprocess.readCountMatrix,
            runReport = Preprocess.countReport,
            templateNotebook = "inspect-hashtag-v3.ipynb",
            dockerRegistry = dockerRegistry
    }

    output {
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

        File? combinedClass = HashedCountMatrix.outClass
        File? combinedCountMatrix = HashedCountMatrix.outCountMatrix
        File? combinedStats = HashedCountMatrix.outStats
        File? combinedLog = HashedCountMatrix.outLog

        File adataRaw = Preprocess.adata
        File adataFinal = UpdateAnnData.outAdata

        File notebookQC = BasicQC.notebook
        File htmlQC = BasicQC.htmlReport
        File adataQC = BasicQC.adata
    }
}
