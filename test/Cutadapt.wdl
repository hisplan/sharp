version 1.0

import "modules/Cutadapt.wdl" as modules

workflow Cutadapt {

    input {
        File fastqR1
        File fastqR2

        Int lengthR1
        Int lengthR2
    }

    call modules.Trim as TrimR1 {
        input:
            fastq = fastqR1,
            length = lengthR1,
            outFileName = "R1.fastq.gz"
    }

    call modules.Trim as TrimR2 {
        input:
            fastq = fastqR2,
            length = lengthR2,
            outFileName = "R2.fastq.gz"
    }
}
