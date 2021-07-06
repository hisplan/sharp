version 1.0

task SanityCheck {

    input {
        File fastqR1
        File fastqR2
        File tagList
        String cbBarcode1
        String cbBarcode2 = ""
        String cbSpacer = ""

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        cbBarcode1 : { help: "e.g. for in_drops4, TCGACATC" }
        cbSpacer : { help: "e.g. for in_drops4, CATG" }
        cbBarcode2 : { help: "e.g. for in_drops4, CTCAGCTA" }
    }

    String dockerImage = dockerRegistry + "/cromwell-seqkit:0.16.1"
    Int numCores = 4
    Float inputSize = size(fastqR1, "GiB") + size(fastqR2, "GiB") + size(tagList, "GiB")

    String sequenceToFind = cbBarcode1 + cbSpacer + cbBarcode2

    String subsetR1FileName = "subset-R1.fastq"
    String subsetR2FileName = "subset-R2.fastq"
    String readIDsFileName = "read-names.txt"
    String countFileName = "read-counts.txt"

    command <<<
        set -euo pipefail

        # find barcode in R1
        seqkit grep -sdip ~{sequenceToFind} ~{fastqR1} > ~{subsetR1FileName}

        # extract read IDs
        grep "@" ~{subsetR1FileName} | awk -F' ' '{ print $1 }' | cut -c2- > ~{readIDsFileName}

        # find read IDs in R2
        seqkit grep -f ~{readIDsFileName} ~{fastqR2}  > ~{subsetR2FileName}

        # count the number of each hashtag in the subset of R2
        touch ~{countFileName}
        hashtags=`cut -f 1 -d, ~{tagList}`
        for hashtag in $hashtags
        do
            count=`grep -c -F "${hashtag}" subset-R2.fastq || true`
            echo "${hashtag}: ${count}" | tee -a ~{countFileName}
        done

    >>>

    output {
        File outSubsetR1 = subsetR1FileName
        File outSubsetR2 = subsetR2FileName
        File outReadNames = readIDsFileName
        File outCount = countFileName
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
