version 1.0

task TranslateFromSeqcSparseBarcodes {

    input {
        File csvFile
    }

    String dockerImage = "hisplan/cromwell-seqc:0.2.4"
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
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}

task TranslateFromSeqcDenseMatrix {

    input {
        File csvFile
    }

    String dockerImage = "hisplan/cromwell-seqc:0.2.4"
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
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}

task NotImplemented {

    command <<<
        set -euo pipefail

        exit 1
    >>>

    runtime {
        docker: "ubuntu:18.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}
