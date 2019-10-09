version 1.0

task HtoDemuxKMeans {

    input {
        File denseCountMatrix
        Array[File] umiCountFiles
    }

    String dockerImage = "hisplan/cromwell-hto-demux-kmeans:0.1"
    Int numCores = 1
    # Float inputSize = size(htoClassification, "GiB") + size(denseCountMatrix, "GiB")

    command <<<
        set -euo pipefail

        mkdir inputs

        cp ~{sep=" " umiCountFiles} ./inputs/

        # --dense-count-matrix: output from SEQC
        #                       e.g. 1187_IL10neg_P163_IGO_09902_8_dense.csv

        # --hto-umi-count-dir:  output directory from CITE-seq-Count
        #                       e.g. .../umi-count

        python3 /opt/demux_kmeans.py \
            --dense-count-matrix ~{denseCountMatrix} \
            --hto-umi-count-dir ./inputs

    >>>

    output {
        File outClass = "final-classification.tsv.gz"
        File outCountMatrix = "final-matrix.tsv.gz"
        File outStats = "stats.yml"
        File outLog = "demux_kmeans.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}
