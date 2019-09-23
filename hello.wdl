version 1.0

import "modules/hello.wdl" as hello

workflow HelloWorld {

    input {
        String name = name
    }

    call hello.say {
        input:
            name = name
    }

    call hello.repeat {
        input:
            message = say.out
    }
}
