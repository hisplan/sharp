version 1.0

import "modules/QC.wdl" as module

workflow QC {

    input {
        File fastqR1
        File fastqR2
        File tagList
        String cbBarcode1
        String cbBarcode2
        String cbSpacer
    }

    call module.QC {
        input:
            fastqR1 = fastqR1,
            fastqR2 = fastqR2,
            tagList = tagList,
            cbBarcode1 = cbBarcode1,
            cbSpacer = cbSpacer,
            cbBarcode2 = cbBarcode2
    }
}
