version 1.0

task HtoDemuxSeurat {

    input {
        Array[File] umiCountFiles
        Float quantile

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/hto-demux-seurat:0.6.0"
    Int numCores = 2
    # Float inputSize = size(input_fastq1, "GiB") + size(input_fastq2, "GiB") + size(input_reference, "GiB")

    command <<<
        set -euo pipefail

        mkdir inputs

        cp ~{sep=" " umiCountFiles} ./inputs/

        mkdir outputs

        Rscript --vanilla \
            /opt/hto-demux.R \
            ./inputs \
            ./outputs \
            ~{quantile}
    >>>

    output {
        # use `outputs/` not `./outputs/` (AWS S3 issue)
        File outClassCsv = "outputs/classification.csv"
        File outFullCsv = "outputs/full-output.csv"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 500 HDD"
        # disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}

task CorrectFalsePositiveDoublets {

    input {
        File htoClassification
        Array[File] umiCountFiles

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/hto-demux-seurat:0.6.0"
    Int numCores = 1
    # Float inputSize = size(htoClassification, "GiB") + size(denseCountMatrix, "GiB")

    command <<<
        set -euo pipefail

        mkdir inputs

        cp ~{sep=" " umiCountFiles} ./inputs/

        # --hto-umi-count-dir:  output directory from CITE-seq-Count
        #                       e.g. .../umi-count

        # --hto-classification: HTO classification from Seurat
        #                       e.g. classification.csv

        python3 /opt/correct_fp_doublets.py \
            --hto-classification ~{htoClassification} \
            --hto-umi-count-dir ./inputs

    >>>

    output {
        File outClass = "classification.tsv.gz"
        File outStats = "stats.yml"
        File outLog = "correct_fp_doublets.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}
