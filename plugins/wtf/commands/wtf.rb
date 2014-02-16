{
    pattern: /^!wtfids\s+([[:word:]♥+-]+)$/,
    channelonly: false,
    command: Proc.new { |wtf_match|
        entry = wtf_match[1].downcase
        entry = [ entry, $watt[entry] ]

        karma = $karmas[entry[0]]
        karma = 0 if !karma

        desc = $watt[entry[0]]
        who = $wfw[entry[0]]
        while desc && (desc[0] == "ref")
            who = $wfw[desc[1]]
            desc = $watt[desc[1]]
        end

        if desc
            if who
                send("PRIVMSG %s :%s (%s: „%s“) hat Karma %i" % [ @target, entry[0], who, desc, karma ])
            elsif entry[1]
                send("PRIVMSG %s :%s („%s“) hat Karma %i" % [ @target, entry[0], desc, karma ])
            else
                send("PRIVMSG %s :%s (keine Beschreibung) hat Karma %i" % [ @target, entry[0], karma ])
            end
        end
    }
}