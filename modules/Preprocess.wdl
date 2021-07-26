version 1.0

import "MergeFastq.wdl" as MergeFastq
import "FastQC.wdl" as FastQC
import "Cutadapt.wdl" as Cutadapt
import "CutInDropSpacer.wdl" as CutInDropSpacer
import "PrepCBWhitelist.wdl" as PrepCBWhitelist
import "CountReads.wdl" as CountReads
import "Count.wdl" as Count
import "AnnData.wdl" as AnnData

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

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        resourceSpec: { help: "memory <= 0 means it will computes required memory for CITE-seq-Count" }
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
            fastqFile = MergeFastqR1.out,
            dockerRegistry = dockerRegistry
    }

    # run FastQC R2
    call FastQC.FastQC as FastQCR2 {
        input:
            fastqFile = MergeFastqR2.out,
            dockerRegistry = dockerRegistry
    }

    # if InDrops v4
    if (scRnaSeqPlatform == "in_drop_v4") {
        # trim R1 (remove the middler spacer as well)
        call CutInDropSpacer.CutInDropSpacer {
            input:
                fastq = MergeFastqR1.out,
                outFileName = "R1.fastq.gz",
                assayVersion = scRnaSeqPlatform,
                dockerRegistry = dockerRegistry
        }
    }

    # if not InDrops v4
    if (scRnaSeqPlatform != "in_drop_v4") {
        # trim R1
        call Cutadapt.Trim as TrimR1 {
            input:
                fastq = MergeFastqR1.out,
                length = lengthR1,
                outFileName = "R1.fastq.gz",
                dockerRegistry = dockerRegistry
        }
    }

    File trimR1 = select_first([CutInDropSpacer.outFile, TrimR1.outFile])

    # trim R2
    call Cutadapt.Trim as TrimR2 {
        input:
            fastq = MergeFastqR2.out,
            length = lengthR2,
            outFileName = "R2.fastq.gz",
            dockerRegistry = dockerRegistry
    }

    # prepare cell barcode whitelist
    if (cellBarcodeWhiteListMethod == "SeqcSparseCountsBarcodesCsv") {
        # *_sparse_counts_barcodes.csv
        call PrepCBWhitelist.WhitelistFromSeqcSparseBarcodes {
            input:
                csvFile = cellBarcodeWhitelistUri,
                dockerRegistry = dockerRegistry
        }
    }

    if (cellBarcodeWhiteListMethod == "SeqcDenseCountsMatrixCsv") {
        # *_dense.csv
        call PrepCBWhitelist.WhitelistFromSeqcDenseMatrix {
            input:
                csvFile = cellBarcodeWhitelistUri,
                dockerRegistry = dockerRegistry
        }
    }

    if (cellBarcodeWhiteListMethod == "10x") {
        call PrepCBWhitelist.WhitelistFrom10x {
            input:
                filteredBarcodes = cellBarcodeWhitelistUri,
                dockerRegistry = dockerRegistry
        }
    }

    File cbWhitelistTemp = select_first([WhitelistFromSeqcSparseBarcodes.out, WhitelistFromSeqcDenseMatrix.out, WhitelistFrom10x.outFilteredBarcodesACGT])

    if (translate10XBarcodes == true) {
        # do translation if necessary
        call PrepCBWhitelist.Translate10XBarcodes {
            input:
                barcodesFile = cbWhitelistTemp,
                dockerRegistry = dockerRegistry
        }
    }

    # pick translated version if available
    File cbWhitelist = select_first([Translate10XBarcodes.out, cbWhitelistTemp])

    call CountReads.CountReads {
        input:
            fastq = trimR1,
            dockerRegistry = dockerRegistry
    }

    # auto compute memory requirement using the number of reads if memory specified <= 0
    if (resourceSpec["memory"] <= 0) {
        # 192 GB if more than 150M reads
        #  64 GB otherwise
        Int memoryComputed = if (CountReads.numOfReads > 150000000) then 192 else 64
    }

    Int memoryRequirement = select_first([memoryComputed, resourceSpec["memory"]])

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
            resourceSpec = {
                "cpu": resourceSpec["cpu"],
                "memory": memoryRequirement
            },
            dockerRegistry = dockerRegistry
    }

    call AnnData.ToAnnData {
        input:
            sampleName = sampleName,
            tagList = tagList,
            umiCountFiles = CiteSeqCount.outUmiCount,
            readCountFiles = CiteSeqCount.outReadCount,
            dockerRegistry = dockerRegistry
    }

    output {
        File fastQCR1Html = FastQCR1.outHtml
        File fastQCR2Html = FastQCR2.outHtml

        File countReport = CiteSeqCount.outReport
        Array[File] umiCountMatrix = CiteSeqCount.outUmiCount
        Array[File] readCountMatrix = CiteSeqCount.outReadCount
        File adata = ToAnnData.outAdata
    }
}
