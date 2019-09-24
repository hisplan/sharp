version 1.0

task RunFastQC {

    input {
        File fastqFile
    }

    Int numCores = 4
    String dockerImage = "hisplan/cromwell-fastqc:0.11.8"
    Float inputSize = size(fastqFile, "GiB")

    command <<<
        set -euo pipefail

        fastqc -o . ~{fastqFile}
    >>>

    output {
        File outHtml = basename(fastqFile, ".fastq.gz") + "_fastqc.html"
        File outZip = basename(fastqFile, ".fastq.gz") + "_fastqc.zip"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 500 HDD"
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
