version 1.0

import "modules/FastQC.wdl" as modules

workflow FastQC {

    input {
        Array[File] fastqFiles
    }

    scatter (fastqFile in fastqFiles) {

        call modules.FastQC {
            input:
                fastqFile = fastqFile
        }
    }
}
