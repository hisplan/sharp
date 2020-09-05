version 1.0

task HashedCountMatrix {

    input {
        File denseCountMatrix
        File htoClassification
        Boolean translate10XBarcodes
    }

    String dockerImage = "hisplan/cromwell-hashed-count-matrix:0.2.0"
    Int numCores = 1
    Float inputSize = size(denseCountMatrix, "GiB") + size(htoClassification, "GiB")

    command <<<
        set -euo pipefail

        python3 /opt/combine.py \
            --dense-count-matrix ~{denseCountMatrix} \
            --hto-classification ~{htoClassification} \
            --10x-whitelist /opt/data/3M-february-2018.txt.gz ~{true="--10x-barcode-translation" false="" translate10XBarcodes}

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
