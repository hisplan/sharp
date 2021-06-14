version 1.0

import "MergeFastq.wdl" as MergeFastq
import "FastQC.wdl" as FastQC
import "Cutadapt.wdl" as Cutadapt
import "CutInDropSpacer.wdl" as CutInDropSpacer
import "PrepCBWhitelist.wdl" as PrepCBWhitelist
import "Count.wdl" as Count

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
    }

    # merge FASTQ R1
    call MergeFastq.MergeFastq as MergeFastqR1 {
        input:
            uriFastq = uriFastqR1,
            sampleName = sampleName,
            readName = "R1"
    }

    # merge FASTQ R2
    call MergeFastq.MergeFastq as MergeFastqR2 {
        input:
            uriFastq = uriFastqR2,
            sampleName = sampleName,
            readName = "R2"
    }

    # run FastQC R1
    call FastQC.FastQC as FastQCR1 {
        input:
            fastqFile = MergeFastqR1.out
    }

    # run FastQC R2
    call FastQC.FastQC as FastQCR2 {
        input:
            fastqFile = MergeFastqR2.out
    }

    # if InDrops v4
    if (scRnaSeqPlatform == "in_drop_v4") {
        # trim R1 (remove the middler spacer as well)
        call CutInDropSpacer.CutInDropSpacer {
            input:
                fastq = MergeFastqR1.out,
                outFileName = "R1.fastq.gz",
                assayVersion = scRnaSeqPlatform
        }
    }

    # if not InDrops v4
    if (scRnaSeqPlatform != "in_drop_v4") {
        # trim R1
        call Cutadapt.Trim as TrimR1 {
            input:
                fastq = MergeFastqR1.out,
                length = lengthR1,
                outFileName = "R1.fastq.gz"
        }
    }

    File trimR1 = select_first([CutInDropSpacer.outFile, TrimR1.outFile])

    # trim R2
    call Cutadapt.Trim as TrimR2 {
        input:
            fastq = MergeFastqR2.out,
            length = lengthR2,
            outFileName = "R2.fastq.gz"
    }

    # prepare cell barcode whitelist
    if (cellBarcodeWhiteListMethod == "SeqcSparseCountsBarcodesCsv") {
        # *_sparse_counts_barcodes.csv
        call PrepCBWhitelist.WhitelistFromSeqcSparseBarcodes {
            input:
                csvFile = cellBarcodeWhitelistUri
        }
    }

    if (cellBarcodeWhiteListMethod == "SeqcDenseCountsMatrixCsv") {
        # *_dense.csv
        call PrepCBWhitelist.WhitelistFromSeqcDenseMatrix {
            input:
                csvFile = cellBarcodeWhitelistUri
        }
    }

    if (cellBarcodeWhiteListMethod == "BarcodeWhitelistCsv") {
        # one barcode per line
        call PrepCBWhitelist.NotImplemented
    }

    File cbWhitelistTemp = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out])

    if (translate10XBarcodes == true) {
        # do translation if necessary
        call PrepCBWhitelist.Translate10XBarcodes {
            input:
                barcodesFile = cbWhitelistTemp
        }
    }

    # pick translated version if available
    File cbWhitelist = select_first([Translate10XBarcodes.out, cbWhitelistTemp])

    # run CITE-seq-Count
    call Count.CiteSeqCount {
        input:
            fastqR1 = trimR1,
            fastqR2 = TrimR2.outFile,
            cbWhiteList = cbWhitelist,
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
            resourceSpec = resourceSpec
    }

    output {
        File fastQCR1Html = FastQCR1.outHtml
        File fastQCR2Html = FastQCR2.outHtml

        File countReport = CiteSeqCount.outReport
        Array[File] umiCountMatrix = CiteSeqCount.outUmiCount
        Array[File] readCountMatrix = CiteSeqCount.outReadCount
    }
}
