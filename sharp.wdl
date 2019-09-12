version 1.0

workflow Sharp {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2
        String sampleName
    }

    call MergeFastq as MergeFastqR1 {
        input:
            uriFastq = uriFastqR1,
            sampleName = sampleName,
            readName = "R1"
    }

    call MergeFastq as MergeFastqR2 {
        input:
            uriFastq = uriFastqR2,
            sampleName = sampleName,
            readName = "R2"
    }

}

task MergeFastq {

    input {
        # set from workflow
        Array[File] uriFastq
        String sampleName
        String readName
    }

    String docker_image = "ubuntu:18.04"
    Int numCores = 11
    # Float input_size = size(input_fastq1, "GiB") + size(input_fastq2, "GiB") + size(input_reference, "GiB")

    command <<<
        set -euo pipefail

        filenames="~{sep=" " uriFastq}"

        echo "${filenames}"

        path_out="~{sampleName}_~{readName}.fastq"

        echo "${path_out}"

        # gunzip and concatenate
        for filename in $filenames
        do
            echo "$filename > ${path_out}"
            gunzip -c ${filename} >> ${path_out}
        done

        # gzip
        gzip ${path_out}
    >>>

    output {
        File out = sampleName + "_" + readName + ".fastq.gz"
    }

    runtime {
        docker: docker_image
        # disks: "local-disk 500 HDD"
        # disks: "local-disk " + ceil(5 * (if input_size < 1 then 1 else input_size )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}
