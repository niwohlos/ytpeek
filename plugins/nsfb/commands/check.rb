{
    pattern: /(https?:\/\/|)(\S+)/i,
    channelonly: false,
    command: Proc.new { |nsfb_match|
        $nsfb["items"].each do |item|
            if /#{item}$/.match(nsfb_match[2])
                send("PRIVMSG %s :Not Safe For Bot!!1elf" % @target)

                break
            end
        end
    }
}