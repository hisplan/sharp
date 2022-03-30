version 1.0

task BasicQC {

    input {
        String sampleName
        File h5ad
        Array[File] readsCount
        File runReport

        String templateNotebook = "inspect-hashtag-v3.ipynb"

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/sharp-basic-qc:0.2.0"
    Float inputSize = size(h5ad, "GiB") + size(readsCount, "GiB") + size(runReport, "GiB")

    String path_outdir = "outputs"

    command <<<
        set -euo pipefail

        # locate reads/matrix.mtx.gz
        mkdir -p reads
        mv ~{sep=" " readsCount} reads/
        read_mtx="reads/matrix.mtx.gz"

        # create a output directory
        mkdir -p ~{path_outdir}

        papermill \
            /opt/~{templateNotebook} ~{sampleName}.QC.ipynb \
            --parameters sample_name ~{sampleName} \
            --parameters path_h5ad ~{h5ad} \
            --parameters path_report ~{runReport} \
            --parameters path_read_mtx ${read_mtx} \
            --parameters path_outdir ~{path_outdir} \
            --stdout-file $(pwd)/~{path_outdir}/~{sampleName}.QC.stdout.txt \
            --log-output

        # html toc with embedded images
        jupyter nbconvert --to html_toc --ExtractOutputPreprocessor.enabled=False ~{sampleName}.QC.ipynb
    >>>

    output {
        File notebook = sampleName + ".QC.ipynb"
        File notebookStdout = path_outdir + "/" + sampleName + ".QC.stdout.txt"
        File htmlReport = sampleName + ".QC.html"
        File adata = path_outdir + "/" + sampleName + ".QC.h5ad"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 4
        memory: "32 GB"
    }
}
