version 1.0

task HashedCountMatrix {

    input {
        File denseCountMatrix
        File htoClassification
    }

    String dockerImage = "hisplan/cromwell-hashed-count-matrix:0.1"
    Int numCores = 1
    Float inputSize = size(denseCountMatrix, "GiB") + size(htoClassification, "GiB")

    command <<<
        set -euo pipefail

        # --dense-count-matrix: output from SEQC
        #                       e.g. 1187_IL10neg_P163_IGO_09902_8_dense.csv

        # --hto-classification: hto classification from either HtoDemuxSeurat or HtoDemuxKMeans
        #                       e.g. final-classification.tsv.gz

        python3 /opt/combine.py \
            --dense-count-matrix ~{denseCountMatrix} \
            --hto-classification ~{htoClassification}

    >>>

    output {
        File outClass = "final-classification.tsv.gz"
        File outCountMatrix = "final-matrix.tsv.gz"
        File outStats = "stats.yml"
        File outLog = "combine.log"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}
