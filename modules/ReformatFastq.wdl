version 1.0

task ReformatAsapSeqFastq {

    input {
        Array[File] fastqR1
        Array[File] fastqR2
        Array[File] fastqR3

        String sampleName
        String conjugation = "TotalSeqA"
        Boolean noReverseComplementR2 = false

        Int numCores

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-asap2kite:0.0.1"
    Float inputSize = size(fastqR1, "GiB") + size(fastqR2, "GiB") + size(fastqR3, "GiB")

    command <<<
        set -euo pipefail

        mkdir -p ./fastq/

        mv ~{sep=" " fastqR1} ./fastq/
        mv ~{sep=" " fastqR2} ./fastq/
        mv ~{sep=" " fastqR3} ./fastq/

        python3 /opt/asap_to_kite_v2.py \
            --fastqs ./fastq/ \
            --sample ~{sampleName} \
            --id ~{sampleName} \
            --conjugation ~{conjugation} \
            --cores ~{numCores} ~{if noReverseComplementR2 then "--no-rc-R2" else ""}
    >>>

    output {
        File outFastqR1 = sampleName + "_R1.fastq.gz"
        File outFastqR2 = sampleName + "_R2.fastq.gz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize )) + " HDD"
        cpu: numCores
        memory: "64 GB"
    }
}
