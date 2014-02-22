{
    pattern: /^!pdp$/,
    channelonly: false,
    command: Proc.new { |wtf_match|
        has_karma = $watt.keys.any? do |key|
            $karmas[key] != 0
        end

        begin
            key = $watt.keys[rand($watt.size)]

            karma = $karmas[key]
        end while has_karma && karma.eql?(0)

        desc = $watt[key]
        who = $wfw[key]
        while desc && (desc[0] == "ref")
            who = $wfw[desc[1]]
            desc = $watt[desc[1]]
        end

        if desc
            if who
                send("PRIVMSG %s :%s (%s: „%s“) hat Karma %i" % [ @target, key, who, desc, karma ])
            elsif $watt[key]
                send("PRIVMSG %s :%s („%s“) hat Karma %i" % [ @target, key, desc, karma ])
            else
                send("PRIVMSG %s :%s (keine Beschreibung) hat Karma %i" % [ @target, key, karma ])
            end
        end
    }
}