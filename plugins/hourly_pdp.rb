{
    name: "hourly_pdp",
    enabled: false,
    help:
    [
    ],
    dependencies:
    [
        "wtf",
    ],
    startup: Proc.new { |name, irc|
        require "date"

        $hourly_pdp = Thread.new do
            until irc.has_joined
            end
            
            date = Date.today
            hour = Time.now.hour
            minute = 13
            second = 37

            while true do
                target = Time.new(date.year, date.month, date.day, hour, minute, second, nil)

                hour += 1
                date = date.next_day hour / 24
                hour = hour % 24

                next if target - Time.now < 0

                Kernel.sleep target - Time.now

                irc.inject(":#{irc.nick} PRIVMSG #{irc.chan} :!pdp")
            end
        end
    },
    shutdown: Proc.new { |name, irc|
        $hourly_pdp.kill
    }
}