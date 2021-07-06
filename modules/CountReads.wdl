version 1.0

task CountReads
{
    input {
        File fastq

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-pigz:2.4"
    Float inputSize = size(fastq, "GiB")

    command <<<
        set -euo pipefail

        pigz -dc ~{fastq} | awk 'NR % 4 == 2' | wc -l
    >>>

    output {
        Int numOfReads = read_int(stdout())
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 10 else inputSize )) + " HDD"
        cpu: 4
        memory: "8 GB"
    }
}
