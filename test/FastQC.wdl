version 1.0

import "modules/FastQC.wdl" as module

workflow FastQC {

    input {
        Array[File] fastqFiles
    }

    scatter (fastqFile in fastqFiles) {

        call module.FastQC {
            input:
                fastqFile = fastqFile
        }
    }
}
