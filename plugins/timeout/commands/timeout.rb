{
    pattern: /^!timeout((\s+[[:word:]]+)*)\s*$/,
    channelonly: true,
    command: Proc.new { |timeout_match|
        p timeout_match

        send("MODE #{@target} +m")

        nicks = []
        nicks << @source if @source
        nicks += timeout_match[1].split if timeout_match[1]

        nicks.each { |nick|
            send("MODE #{@target} -a #{nick}")
            send("MODE #{@target} -o #{nick}")
            send("MODE #{@target} -h #{nick}")
            send("MODE #{@target} -v #{nick}")
        }
    },
}
