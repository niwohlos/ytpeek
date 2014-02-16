{
    pattern: /^([[:word:]♥+-]+)(\+\+|--)$/,
    channelonly: true,
    command: Proc.new { |karma_match|
        who = karma_match[1].downcase
        if @source && (who == @source.downcase)
            send("PRIVMSG %s :Wage es ja nicht, %s..." % [ @chan, inmatch ])
        else
            $karmas[who] = 0 if !$karmas[who]

            if karma_match[2] == "++"
                if $nazistuff.include?(who)
                    send("MODE %s -Q" % [ @chan ])
                    send("KICK %s %s :nazi" % [ @chan, inmatch ])
                    send("MODE %s +Q" % [ @chan ])
                elsif $last_incer[who] && ($last_incer[who][0] == @source.downcase) && (Time.new - $last_incer[who][1] < 600)
                    send("PRIVMSG %s :%s: Och nö, nicht schon wieder..." % [ @chan, @source ])
                else
                    $karmas[who] += 1
                    $last_incer[who] = [ @source.downcase, Time.new ]
                end
            else
                if $last_decer[who] && ($last_decer[who][0] == @source.downcase) && (Time.new - $last_decer[who][1] < 600)
                    send("PRIVMSG %s :%s: Och nö, nicht schon wieder..." % [ @chan, @source ])
                else
                    $karmas[who] -= 1
                    $last_decer[who] = [ @source.downcase, Time.new ]
                end
            end
        end
    }
}