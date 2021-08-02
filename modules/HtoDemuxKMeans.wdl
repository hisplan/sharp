version 1.0

task HtoDemuxKMeans {

    input {
        Array[File] umiCountFiles
        Int minCount=0
        Int mode=1

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        mode: { help: "1=default, 2=noisy methanol, 3=aggressively rescue from doublets" }
    }

    String dockerImage = dockerRegistry + "/hto-demux-kmeans:0.5.0"
    Int numCores = 1
    Float inputSize = size(umiCountFiles, "GiB")

    command <<<
        set -euo pipefail

        mkdir inputs

        cp ~{sep=" " umiCountFiles} ./inputs/

        # --hto-umi-count-dir:  output directory from CITE-seq-Count
        #                       e.g. .../umi-count
        # --mode: 1=default, 2=noisy methanol, 3=aggressively rescue from doublets

        python3 /opt/demux_kmeans.py \
            --hto-umi-count-dir ./inputs \
            --min-count ~{minCount} \
            --mode ~{mode}

    >>>

    output {
        File outClass = "classification.tsv.gz"
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
