version 1.0

import "modules/CutInDropSpacer.wdl" as module

workflow CutInDropSpacer {

    input {
        File fastq
        String assayVersion = "2"
        String outFileName
    }

    call module.CutInDropSpacer {
        input:
            fastq = fastq,
            assayVersion = assayVersion,
            outFileName = outFileName
    }

}
