version 1.0

import "modules/ReformatFastq.wdl" as module

workflow ReformatFastq {

    input {
        Array[File] fastqR1
        Array[File] fastqR2
        Array[File] fastqR3

        String sampleName
        String conjugation
        Boolean noReverseComplementR2

        Int numCores

        # docker-related
        String dockerRegistry
    }

    call module.ReformatAsapSeqFastq {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            fastqR3 = fastqR3,
            sampleName = sampleName,
            conjugation = conjugation,
            numCores = numCores,
            dockerRegistry = dockerRegistry
    }

    output {
        File outFastqR1 = ReformatAsapSeqFastq.outFastqR1
        File outFastqR2 = ReformatAsapSeqFastq.outFastqR2
    }
}
