version 1.0

task CiteSeqToAnnData {

    input {
        String sampleName
        File tagList
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-hto-adt-postprocess:0.3.2"
    Int numCores = 1
    Float inputSize = size(umiCountFiles, "GiB") + size(readCountFiles, "GiB") + size(tagList, "GiB")

    command <<<
        set -euo pipefail

        mkdir umi-counts
        cp ~{sep=" " umiCountFiles} ./umi-counts/

        mkdir read-counts
        cp ~{sep=" " readCountFiles} ./read-counts/

        python3 /opt/citeseq_to_adata.py \
            --sample ~{sampleName} \
            --tag-list ~{tagList} \
            --umi-counts ./umi-counts/ \
            --read-counts ./read-counts/

    >>>

    output {
        File outAdata = sampleName + ".CITE-seq.h5ad"
        File outLog = "citeseq_to_adata.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}
