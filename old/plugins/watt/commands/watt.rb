{
    pattern: /^\?\?\s*([[:word:]♥+-]+)$/,
    channelonly: false,
    command: Proc.new { |watt_match|
        desc = $watt[watt_match[1].downcase]
        who = $wfw[watt_match[1].downcase]
        while desc && (desc[0] == "ref")
            who = $wfw[desc[1]]
            desc = $watt[desc[1]]
        end
        if desc
            if who
                send("PRIVMSG %s :%s: „%s“ (von %s)" % [ @target, watt_match[1], desc, who ]) if desc
            else
                send("PRIVMSG %s :%s: „%s“" % [ @target, watt_match[1], desc ]) if desc
            end
        end
    }
}