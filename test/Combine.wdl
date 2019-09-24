version 1.0

import "modules/Combine.wdl" as modules

workflow Combine {

    input {
        File denseCountMatrix
        File htoDemuxMatrix
        File htoDemuxUnmapped
    }

    call modules.GenerateHashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoDemuxMatrix = htoDemuxMatrix,
            htoDemuxUnmapped = htoDemuxUnmapped
    }

    output {
        File outClass = GenerateHashedCountMatrix.outClass
        File outCountMatrix = GenerateHashedCountMatrix.outCountMatrix
    }
}
