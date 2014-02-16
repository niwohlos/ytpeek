{
    pattern: /^!karma$/,
    channelonly: false,
    command: Proc.new { |karma_req_match|
        resp = @source
        karma = $karmas[resp.downcase]
        karma = 0 if !karma
        send("PRIVMSG %s :%s hat Karma %i" % [ @target, resp, karma ])
    }
}