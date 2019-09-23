version 1.0

import "modules/MergeFastq.wdl" as modules

workflow Sharp {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2
        String sampleName
    }

    call modules.MergeFastq as MergeFastqR1 {
        input:
            uriFastq = uriFastqR1,
            sampleName = sampleName,
            readName = "R1"
    }

    call modules.MergeFastq as MergeFastqR2 {
        input:
            uriFastq = uriFastqR2,
            sampleName = sampleName,
            readName = "R2"
    }

}
