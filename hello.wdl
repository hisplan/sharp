version 1.0

workflow HelloWorld {

    input {
        String name = name
    }

    call say {
        input:
            name = name
    }

    call repeat {
        input:
            message = say.out
    }
}

task say {

    input {
        String name
    }

    command {
        set -euo pipefail

        echo "Hello, World! ~{name}"
    }

    output {
        String out = read_string(stdout())
    }

    runtime {
        docker: "ubuntu:18.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}

task repeat {

    input {
        String message
    }

    command {
        set -euo pipefail

        echo "REPEAT: ~{message}"
    }

    output {
        String out = read_string(stdout())
    }

    runtime {
        docker: "ubuntu:18.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}
