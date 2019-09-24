version 1.0

import "modules/HtoDemux.wdl" as modules

workflow HtoDemux {

    input {
        Array[File] umiCountFiles
        Float quantile
    }

    call modules.RunHtoDemux {
        input:
            umiCountFiles = umiCountFiles,
            quantile = quantile
    }
}
