version 1.0

workflow HtoDemux {

    input {
        Array[File] umiCountFiles
        Float quantile
    }

    # call DownloadMatrix {
    #     input:
    #         uriUmiCountMatrix = uriUmiCountMatrix
    # }

    call RunDemux {
        input:
            umiCountFiles = umiCountFiles,
            quantile = quantile
    }
}

# task DownloadMatrix {

#     input {
#         String uriUmiCountMatrix
#     }

#     command <<<
#         set -euo pipefail

#         #fixme: GCP vs. AWS?
#         # gsutil sync ~{uriUmiCountMatrix} ./umit-count
#         which gsutil
#     >>>

#     output {
#         String out = read_string(stdout())
#     }

#     runtime {
#         docker: "ubuntu:18.04"
#         disks: "local-disk 100 HDD"
#         cpu: 1
#         memory: "1 GB"
#     }
# }

task RunDemux {

    input {
        Array[File] umiCountFiles
        Float quantile
    }

    String dockerImage = "hisplan/cromwell-hto-demux:0.1"
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
        File outClassCsv = "./outputs/classification.csv"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 500 HDD"
        # disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
