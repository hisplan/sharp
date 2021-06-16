version 1.0

import "modules/MergeFastq.wdl" as module

workflow MergeFastq {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2

        String sampleName
    }

    # merge FASTQ R1
    call module.MergeFastq as MergeFastqR1 {
        input:
            uriFastq = uriFastqR1,
            sampleName = sampleName,
            readName = "R1"
    }

    # merge FASTQ R2
    call module.MergeFastq as MergeFastqR2 {
        input:
            uriFastq = uriFastqR2,
            sampleName = sampleName,
            readName = "R2"
    }

    output {
        File fastqR1 = MergeFastqR1.out
        File fastqR2 = MergeFastqR2.out
    }
}
