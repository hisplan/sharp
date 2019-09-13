version 1.0

workflow FastQC {

    input {
        Array[File] fastqFiles
    }

    scatter (fastqFile in fastqFiles) {

        call RunFastQC {
            input:
                fastqFile = fastqFile
        }
    }
}

task RunFastQC {

    input {
        File fastqFile
    }

    Int numCores = 4
    String docker_image = "hisplan/cromwell-fastqc:0.11.8"

    command <<<
        set -euo pipefail

        /usr/local/bin/fastqc \
            -o . ~{fastqFile}
    >>>

    output {
        File outHtml = basename(fastqFile, ".fastq.gz") + "_fastqc.html"
        File outZip = basename(fastqFile, ".fastq.gz") + "_fastqc.zip"
    }

    runtime {
        docker: docker_image
        disks: "local-disk 500 HDD"
        # disks: "local-disk " + ceil(5 * (if input_size < 1 then 1 else input_size )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
