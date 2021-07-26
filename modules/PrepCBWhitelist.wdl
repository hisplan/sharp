version 1.0

task WhitelistFromSeqcSparseBarcodes {

    input {
        File csvFile

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-seqc:0.2.9"
    Int numCores = 1
    Float inputSize = size(csvFile, "GiB")

    command <<<
        set -euo pipefail

        python - << EOF
        import pandas as pd
        from seqc.sequence.encodings import DNA3Bit

        df = pd.read_csv(
            "~{csvFile}",
            header=None, usecols=[1], names=["cb"]
        )

        dna3bit = DNA3Bit()

        cb_whitelist = df.cb.apply(lambda cb: dna3bit.decode(cb).decode())

        cb_whitelist.to_csv(
            "cb-whitelist.txt",
            header=False, index=False
        )
        EOF
    >>>

    output {
        File out = "cb-whitelist.txt"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}

task WhitelistFromSeqcDenseMatrix {

    input {
        File csvFile

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-seqc:0.2.9"
    Int numCores = 1
    Float inputSize = size(csvFile, "GiB")

    command <<<
        set -euo pipefail

        python - << EOF
        import pandas as pd
        from seqc.sequence.encodings import DNA3Bit

        df = pd.read_csv(
            "~{csvFile}",
            index_col=0
        )

        dna3bit = DNA3Bit()

        # generate CB whitelist based on SEQC results
        cb_whitelist = df.index.map(lambda x: dna3bit.decode(x).decode()).sort_values().to_frame()

        cb_whitelist.to_csv(
            "cb-whitelist.txt",
            header=False, index=False
        )
        EOF
    >>>

    output {
        File out = "cb-whitelist.txt"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize )) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}

task WhitelistFrom10x {

    input {
        File filteredBarcodes

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-utils:0.5.0"
    Float inputSize = size(filteredBarcodes, "GiB")

    command <<<
        set -euo pipefail

        # get the error-corrected barcodes from the counts matrix
        python3 /opt/extract_barcodes.py \
            --input ~{filteredBarcodes} \
            --outdir results
    >>>

    output {
        File outFilteredBarcodesACGT = "results/barcodes.acgt.txt"
        File outFilteredBarcodes1234 = "results/barcodes.1234.txt"
        File outLog = "extract_barcodes.log"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "16 GB"
        preemptible: 0
    }
}

task Translate10XBarcodes {

    input {
        File barcodesFile

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-utils:0.5.0"
    Int numCores = 1
    Float inputSize = size(barcodesFile, "GiB")

    command <<<
        set -euo pipefail

        python3 /opt/translate_10x_barcodes.py \
            --input-file ~{barcodesFile} \
            --10x-whitelist /opt/data/3M-february-2018.txt.gz
    >>>

    output {
        File out = "translated-barcodes.txt"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize )) + " HDD"
        cpu: numCores
        memory: "4 GB"
    }
}

task NotImplemented {

    command <<<
        set -euo pipefail

        exit 1
    >>>

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}
