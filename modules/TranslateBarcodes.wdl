version 1.0

task Translate10XBarcodes {

    input {
        Array[File] umiCountFiles
        Array[File] readCountFiles

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/hto-adt-postprocess:0.3.4"
    Int numCores = 1
    Float inputSize = size(umiCountFiles, "GiB") + size(readCountFiles, "GiB")

    command <<<
        set -euo pipefail

        mkdir umis
        cp ~{sep=" " umiCountFiles} ./umis/

        mkdir reads
        cp ~{sep=" " umiCountFiles} ./reads/

        python3 /opt/translate_barcodes.py \
            --barcodes ./umis/barcodes.tsv.gz \
            --hto-gex-mapper /opt/data/10x-hto-gex-mapper.pickle

        mv barcodes-translated.tsv.gz ./umis/barcodes.tsv.gz

        python3 /opt/translate_barcodes.py \
            --barcodes ./reads/barcodes.tsv.gz \
            --hto-gex-mapper /opt/data/10x-hto-gex-mapper.pickle

        mv barcodes-translated.tsv.gz ./reads/barcodes.tsv.gz
    >>>

    output {
        Array[File] outUmiCountFiles = glob("./umis/*")
        Array[File] outReadCountFiles = glob("./reads/*")
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "4 GB"
    }
}
