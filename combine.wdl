version 1.0

workflow Combine {

    input {
        File denseCountMatrix
        File htoDemuxMatrix
        File htoDemuxUnmapped
    }

    call GenerateHashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoDemuxMatrix = htoDemuxMatrix,
            htoDemuxUnmapped = htoDemuxUnmapped
    }

    output {
        File outClass = GenerateHashedCountMatrix.outClass
        File outCountMatrix = GenerateHashedCountMatrix.outCountMatrix
    }
}

task GenerateHashedCountMatrix {

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
        File outClass = "final-classifiation.tsv"
        File outCountMatrix = "final-matrix.tsv"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}
