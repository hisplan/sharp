version 1.0

import "modules/MergeFastq.wdl" as MergeFastq
import "modules/FastQC.wdl" as FastQC
import "modules/Cutadapt.wdl" as Cutadapt
import "modules/CutInDropSpacer.wdl" as CutInDropSpacer
import "modules/PrepCBWhitelist.wdl" as PrepCBWhitelist
import "modules/Count.wdl" as Count
import "modules/HtoDemuxSeurat.wdl" as HtoDemuxSeurat
import "modules/HtoDemuxKMeans.wdl" as HtoDemuxKMeans
import "modules/Combine.wdl" as Combine

workflow Sharp {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2

        Int lengthR1
        Int lengthR2

        String sampleName

        File cellBarcodeWhitelistUri
        String cellBarcodeWhiteListMethod

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

        Int numCoresForCount

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

    File cbWhitelist = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out])

    # run CITE-seq-Count
    call Count.CiteSeqCount {
        input:
            fastqR1 = trimR1,
            fastqR2 = TrimR2.outFile,
            cbWhiteList = cbWhitelist,
            hashTagList = hashTagList,
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
            numCores = numCoresForCount
    }

    # HTO demux using KMeans
    call HtoDemuxKMeans.HtoDemuxKMeans {
        input:
            umiCountFiles = CiteSeqCount.outUmiCount
    }

    # HTO demux using Seurat
    if (runSeuratDemux == true) {

        call HtoDemuxSeurat.HtoDemuxSeurat {
            input:
                umiCountFiles = CiteSeqCount.outUmiCount,
                quantile = 0.99
        }

        # correct false positive doublets frm Seurat output
        call HtoDemuxSeurat.CorrectFalsePositiveDoublets {
            input:
                htoClassification = HtoDemuxSeurat.outClassCsv,
                umiCountFiles = CiteSeqCount.outUmiCount
        }
    }

    # combine count matrix with hashtag
    call Combine.HashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoClassification = HtoDemuxKMeans.outClass
    }

    output {
        File fastQCR1Html = FastQCR1.outHtml
        File fastQCR2Html = FastQCR2.outHtml

        File countReport = CiteSeqCount.outReport
        Array[File] umiCountMatrix = CiteSeqCount.outUmiCount
        Array[File] readCountMatrix = CiteSeqCount.outReadCount

        File htoClassification = HtoDemuxKMeans.outClass
        File? htoClassification_Suppl1 = HtoDemuxSeurat.outClassCsv
        File? htoClassification_Suppl2 = HtoDemuxSeurat.outFullCsv
        File? htoClassification_Suppl3 = CorrectFalsePositiveDoublets.outClass

        File statsHtoDemux = HtoDemuxKMeans.outStats
        File? statsHtoDemux_Suppl1 = CorrectFalsePositiveDoublets.outStats

        File logHtoDemux = HtoDemuxKMeans.outLog
        File? logHtoDemux_Suppl1 = CorrectFalsePositiveDoublets.outLog

        File combinedClass = HashedCountMatrix.outClass
        File combinedCountMatrix = HashedCountMatrix.outCountMatrix
        File combinedStats = HashedCountMatrix.outStats
        File combinedLog = HashedCountMatrix.outLog
    }
}
