version 1.0

import "modules/SanityCheck.wdl" as module

workflow SanityCheck {

    input {
        File fastqR1
        File fastqR2
        File tagList
        String cbBarcode1
        String cbBarcode2
        String cbSpacer

        # docker-related
        String dockerRegistry
    }

    call module.SanityCheck {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            tagList = tagList,
            cbBarcode1 = cbBarcode1,
            cbSpacer = cbSpacer,
            cbBarcode2 = cbBarcode2,
            dockerRegistry = dockerRegistry
    }
}
