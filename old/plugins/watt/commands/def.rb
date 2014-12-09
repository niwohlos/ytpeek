{
    pattern: /^\?!\s*([[:word:]♥+-]+)\s*=\s*(.*)$/,
    channelonly: true,
    command: Proc.new { |def_match|
        ndesc = def_match[2]
        dest = def_match[1].downcase

        if /^\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])
            ndesc = $watt[/^\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])[1].downcase]
        elsif /^&\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])
            reftarget = /^&\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])[1].downcase
            if reftarget != dest
                desc = $watt[reftarget]
                while desc && (desc[0] == "ref") && (desc[1] != dest)
                    desc = $watt[desc[1]]
                end
            end
            if (reftarget == dest) || (desc && (desc[0] == "ref"))
                send("PRIVMSG %s :%s: Du willst mich wohl verarschen; bastel dir doch aus zyklischen Graphen deinen Galgen, aber lass mich in Ruhe kthxbye -.-" % [ @chan, @source ])
                ndesc = nil
            else
                ndesc = [ "ref", reftarget ]
            end
        end
        if ndesc
            $watt[dest] = ndesc
            $wfw[dest] = @source
        end
    }
}