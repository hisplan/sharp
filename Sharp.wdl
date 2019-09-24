version 1.0

import "modules/MergeFastq.wdl" as MergeFastq
import "modules/FastQC.wdl" as FastQC

workflow Sharp {

    input {
        Array[File] uriFastqR1
        Array[File] uriFastqR2
        String sampleName
    }

    # merge FASTQ R1
    call MergeFastq.MergeFastq as MergeFastqR1 {
        input:
            uriFastq = uriFastqR1,
            sampleName = sampleName,
            readName = "R1"
    }

    # merge FASTQ R2
    call MergeFastq.MergeFastq as MergeFastqR2 {
        input:
            uriFastq = uriFastqR2,
            sampleName = sampleName,
            readName = "R2"
    }

    # run FastQC R1
    call FastQC.RunFastQC as FastQCR1 {
        input:
            fastqFile = MergeFastqR1.out
    }

    # run FastQC R2
    call FastQC.RunFastQC as FastQCR2 {
        input:
            fastqFile = MergeFastqR2.out
    }

    output {
        File outFastQCR1Html = FastQCR1.outHtml
        File outFastQCR2Html = FastQCR2.outHtml
    }
}
