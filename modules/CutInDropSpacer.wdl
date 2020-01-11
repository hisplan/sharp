version 1.0

task CutInDropSpacer {

    input {
        File fastq
        String assayVersion = "2"
        String outFileName
    }

    String dockerImage = "hisplan/cromwell-cut-indrop-spacer:0.2"
    Int numCores = 4
    Float inputSize = size(fastq, "GiB") * 2

    command <<<
        set -euo pipefail

        python3 /opt/cut_indrop_spacer.py \
            --in ~{fastq} \
            --out ~{outFileName} \
            --assay-version ~{assayVersion}
    >>>

    output {
        File outFile = outFileName
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
