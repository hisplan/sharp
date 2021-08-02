version 1.0

task ToAnnData {

    input {
        String sampleName
        File tagList
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/hto-adt-postprocess:0.3.3"
    Int numCores = 1
    Float inputSize = size(umiCountFiles, "GiB") + size(readCountFiles, "GiB") + size(tagList, "GiB")

    command <<<
        set -euo pipefail

        mkdir umi-counts
        mv ~{sep=" " umiCountFiles} ./umi-counts/

        mkdir read-counts
        mv ~{sep=" " readCountFiles} ./read-counts/

        python3 /opt/to_adata.py \
            --sample ~{sampleName} \
            --tag-list ~{tagList} \
            --umi-counts ./umi-counts/ \
            --read-counts ./read-counts/

    >>>

    output {
        File outAdata = sampleName + ".h5ad"
        File outLog = "to_adata.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}

task UpdateAnnData {

    input {
        String sampleName
        File htoClassification
        File adata
        Boolean translate10XBarcodes

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/hto-adt-postprocess:0.3.3"
    Int numCores = 1
    Float inputSize = size(htoClassification, "GiB") + size(adata, "GiB")

    command <<<
        set -euo pipefail

        mv ~{adata} adata-in.h5ad

        python3 /opt/update_adata.py \
            --class ~{htoClassification} \
            --adata-in adata-in.h5ad \
            --adata-out ~{sampleName}.h5ad \
            --hto-gex-mapper /opt/data/10x-hto-gex-mapper.pickle ~{true="--10x-barcode-translation" false="" translate10XBarcodes}

    >>>

    output {
        File outAdata = sampleName + ".h5ad"
        File outLog = "update_adata.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}
