version 1.0

import "modules/BasicQC.wdl" as module

workflow BasicQC {

    input {
        String sampleName
        File h5ad
        Array[File] readsCount
        File runReport

        String templateNotebook = "inspect-hashtag-v3.ipynb"

        # docker-related
        String dockerRegistry
    }

    call module.BasicQC {
        input:
            sampleName = sampleName,
            h5ad = h5ad,
            readsCount = readsCount,
            runReport = runReport,
            templateNotebook = templateNotebook,
            dockerRegistry = dockerRegistry
    }

    output {
        File notebook = BasicQC.notebook
        File notebookStdout = BasicQC.notebookStdout
        File htmlReport = BasicQC.htmlReport
        File adata = BasicQC.adata
    }
}
