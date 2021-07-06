version 1.0

task Trim {

    input {
        File fastq
        Int length
        String outFileName

        # docker-related
        String dockerRegistry
    }

    Int numCores = 4
    String dockerImage = dockerRegistry + "/cromwell-cutadapt:2.5"

    command <<<
        set -euo pipefail

        cutadapt \
            --minimum-length ~{length} \
            --length ~{length} \
            --too-short-output too-short.~{outFileName} \
            --too-long-output too-long.~{outFileName} \
            -o ~{outFileName} \
            ~{fastq}

    >>>

    output {
        File outFile = outFileName
        Array[File] outTooShortTooLongFiles = glob("too-*." + outFileName)

        # fixme: WDL/Cromwell doesn't support optional
        # File? outTooShortFile = "too-short." + outFileName
        # File? outTooLongFile = "too-long." + outFileName
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 500 HDD"
        # disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
