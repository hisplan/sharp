version 1.0

task CiteSeqCount {

    input {
        File fastqR1
        File fastqR2
        File cbWhiteList
        File tagList

        # cellular barcode
        Int cbStartPos
        Int cbEndPos

        # UMI
        Int umiStartPos
        Int umiEndPos

        # how many bases should we trim before starting to look for hashtag sequence
        Int trimPos

        # activate sliding window alignement
        Boolean slidingWindowSearch

        # correction
        Int cbCollapsingDistance
        Int umiCollapsingDistance
        Int maxTagError

        Int numExpectedCells

        Map[String, Int] resourceSpec

        # docker-related
        String dockerRegistry
        String version = "1.4.2-develop"
    }

    String dockerImage = dockerRegistry + "/cromwell-cite-seq-count:" + version
    Float inputSize = size(fastqR1, "GiB") + size(fastqR2, "GiB") + size(cbWhiteList, "GiB") + size(tagList, "GiB")

    # https://hoohm.github.io/CITE-seq-Count/Running-the-script/
    command <<<
        set -euo pipefail

        # preserve one core for the main process just in case
        let n_threads=~{resourceSpec["cpu"]}-1

        CITE-seq-Count \
            -R1 ~{fastqR1} \
            -R2 ~{fastqR2} \
            --tags ~{tagList} \
            -cbf ~{cbStartPos} -cbl ~{cbEndPos} \
            -umif ~{umiStartPos} -umil ~{umiEndPos} \
            --bc_collapsing_dist ~{cbCollapsingDistance} \
            --umi_collapsing_dist ~{umiCollapsingDistance} \
            --max-error ~{maxTagError} \
            --start-trim ~{trimPos} ~{true='--sliding-window' false='' slidingWindowSearch} \
            --expected_cells ~{numExpectedCells} \
            --whitelist ~{cbWhiteList} \
            --output results \
            --unmapped-tags unmapped.csv \
            --threads ${n_threads}
    >>>

    output {
        # File outUmiDenseCount = "results/dense_umis.tsv"
        File outUnmapped = "results/unmapped.csv"
        File outReport = "results/run_report.yaml"
        File outUncorrected = "results/uncorrected_cells/dense_umis.tsv"

        Array[File] outUmiCount = glob("results/umi_count/*")
        Array[File] outReadCount = glob("results/read_count/*")
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 10 else inputSize )) + " HDD"
        cpu: resourceSpec["cpu"]
        memory: resourceSpec["memory"] + " GB"
        # preemptible: 0
    }

}
