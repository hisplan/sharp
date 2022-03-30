version 1.0

import "modules/Preprocess.wdl" as Preprocess
import "modules/BasicQC.wdl" as BasicQC

workflow CiteSeq {

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

        # docker-related
        String dockerRegistry
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
            dockerRegistry = dockerRegistry
    }
    
    call BasicQC.BasicQC {
        input:
            sampleName = sampleName,
            h5ad = Preprocess.adata,
            readsCount = Preprocess.readCountMatrix,
            runReport = Preprocess.countReport,
            templateNotebook = "inspect-citeseq-v3.ipynb",
            dockerRegistry = dockerRegistry
    }

    output {
        File fastQCR1Html = Preprocess.fastQCR1Html
        File fastQCR2Html = Preprocess.fastQCR2Html

        File countReport = Preprocess.countReport
        Array[File] umiCountMatrix = Preprocess.umiCountMatrix
        Array[File] readCountMatrix = Preprocess.readCountMatrix

        File adata = Preprocess.adata

        File notebookQC = BasicQC.notebook
        File htmlQC = BasicQC.htmlReport
        File adataQC = BasicQC.adata        
    }
}
