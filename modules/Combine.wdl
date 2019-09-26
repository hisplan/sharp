version 1.0

task HashedCountMatrix {

    input {
        File denseCountMatrix
        File htoDemuxMatrix
        File htoDemuxUnmapped
    }

    String dockerImage = "hisplan/cromwell-hashed-count-matrix:0.1"
    Int numCores = 1
    Float inputSize = size(denseCountMatrix, "GiB") + size(htoDemuxMatrix, "GiB") + size(htoDemuxUnmapped, "GiB")

    command <<<
        set -euo pipefail

        # --dense-count-matrix: output from SEQC
        #                       e.g. 1187_IL10neg_P163_IGO_09902_8_dense.csv

        # --hto-demux-matrix:   output from modified Seurat HtoDemux
        #                       e.g. classification.csv

        # --hto-demux-unmapped: output from CITE-seq-Count
        #                       e.g. IL10neg_HTO.unmapped.csv

        python3 /opt/combine.py \
            --dense-count-matrix ~{denseCountMatrix} \
            --hto-demux-matrix ~{htoDemuxMatrix} \
            --hto-demux-unmapped ~{htoDemuxUnmapped}

    >>>

    output {
        File outClass = "final-classification.tsv.gz"
        File outCountMatrix = "final-matrix.tsv.gz"
        File outStats = "stats.yml"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}

task CorrectFalsePositiveDoublets {

    input {
        File htoClassification
        File denseCountMatrix
        Array[File] umiCountFiles
    }

    String dockerImage = "hisplan/cromwell-hashed-count-matrix:0.1"
    Int numCores = 1
    # Float inputSize = size(htoClassification, "GiB") + size(denseCountMatrix, "GiB") + size(htoDemuxUnmapped, "GiB")

    command <<<
        set -euo pipefail

        mkdir inputs

        cp ~{sep=" " umiCountFiles} ./inputs/

        # --dense-count-matrix: output from SEQC
        #                       e.g. 1187_IL10neg_P163_IGO_09902_8_dense.csv

        # --hto-umi-count-dir:  output directory from CITE-seq-Count
        #                       e.g. .../umi-count

        # --hto-classification: final HTO classification
        #                       e.g. final-classification.csv

        python3 /opt/correct_fp_doublets.py \
            --hto-classification ~{htoClassification} \
            --dense-count-matrix ~{denseCountMatrix} \
            --hto-umi-count-dir ./inputs

    >>>

    output {
        File outClass = "final-classification.tsv.gz"
        File outCountMatrix = "final-matrix.tsv.gz"
        File outStats = "stats.yml"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}
