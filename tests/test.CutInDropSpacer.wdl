version 1.0

import "modules/CutInDropSpacer.wdl" as module

workflow CutInDropSpacer {

    input {
        File fastq
        String assayVersion = "2"
        String outFileName

        # docker-related
        String dockerRegistry
    }

    call module.CutInDropSpacer {
        input:
            fastq = fastq,
            assayVersion = assayVersion,
            outFileName = outFileName,
            dockerRegistry = dockerRegistry
    }

}
