version 1.0

import "modules/CountReads.wdl" as module

workflow CountReads {

    input {
        File fastq

        # docker-related
        String dockerRegistry
    }

    call module.CountReads {
        input:
            fastq = fastq,
            dockerRegistry = dockerRegistry
    }

    output {
        Int reads = CountReads.numOfReads
    }
}
