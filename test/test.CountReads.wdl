version 1.0

import "modules/CountReads.wdl" as module

workflow CountReads {

    input {
        File fastq
    }

    call module.CountReads {
        input:
            fastq = fastq
    }

    output {
        Int reads = CountReads.numOfReads
    }
}
