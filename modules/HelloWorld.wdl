version 1.0

task Say {

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

task Repeat {

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
