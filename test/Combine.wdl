version 1.0

import "modules/Combine.wdl" as modules

workflow Combine {

    input {
        File denseCountMatrix
        File htoDemuxMatrix
        File htoDemuxUnmapped
    }

    call modules.HashedCountMatrix {
        input:
            denseCountMatrix = denseCountMatrix,
            htoDemuxMatrix = htoDemuxMatrix,
            htoDemuxUnmapped = htoDemuxUnmapped
    }

    output {
        File outClass = HashedCountMatrix.outClass
        File outCountMatrix = HashedCountMatrix.outCountMatrix
    }
}
