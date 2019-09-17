version 1.0

workflow Cutadapt {

    input {
        File uriFastqR1
        File uriFastqR2

        Int lengthR1
        Int lengthR2
    }

    call Trim as TrimR1 {
        input:
            uriFastq = uriFastqR1,
            length = lengthR1,
            outFileName = "R1.fastq.gz"
    }

    call Trim as TrimR2 {
        input:
            uriFastq = uriFastqR2,
            length = lengthR2,
            outFileName = "R2.fastq.gz"
    }
}

task Trim {

    input {
        File uriFastq
        Int length
        String outFileName
    }

    Int numCores = 4
    String dockerImage = "hisplan/cromwell-cutadapt:2.5"

    command <<<
        set -euo pipefail

        cutadapt \
            --minimum-length ~{length} \
            --length ~{length} \
            --too-short-output too-short.~{outFileName} \
            --too-long-output too-long.~{outFileName} \
            -o ~{outFileName} \
            ~{uriFastq}

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
