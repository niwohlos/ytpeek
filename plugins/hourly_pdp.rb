{
    name: "hourly_pdp",
    enabled: true,
    config:
    {
        # :years, :months :days, :hours, :minutes, :seconds
        granularity: :hours,
        duration: 1,
        neat: true,
    },
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
            
            config = irc.plugins.select{|hash| hash.name.eql? name}.shift.config
            granularity = { years: 6, months: 5, days: 4, hours: 3, minutes: 2, seconds: 1 }[config.granularity]

            granularity += 1 if config.neat
            
            date = Date.today
            year = date.year
            month = date.month
            day = date.day
            time = Time.now
            hour = time.hour
            minute = time.min
            second = time.sec

            while granularity > 0
                granularity -= 1

                case granularity
                when 5
                    month = 1
                when 4
                    day = 1
                when 3
                    hour = 0
                when 2
                    minute = 0
                when 1
                    second = 0
                end
            end

            date = Date.new year, month, day

            while true do
                granularity = { years: 1, months: 2, days: 3, hours: 4, minutes: 5, seconds: 6 }[config.granularity]

                while granularity > 0
                    granularity -= 1

                    case granularity
                    when 5
                        second += config.duration if config.granularity.eql? :seconds
                        minute += second / 60
                        second = second % 60
                    when 4
                        minute += config.duration if config.granularity.eql? :minutes
                        hour += minute / 60
                        minute = minute % 60
                    when 3
                        hour += config.duration if config.granularity.eql? :hours
                        date.next_day hour / 24
                        hour = hour % 24
                    when 2
                        date = date.next_day config.duration if config.granularity.eql? :days
                    when 1
                        date = date.next_month config.duration if config.granularity.eql? :months
                    when 0
                        date = date.next_year config.duration if config.granularity.eql? :years
                    end
                end

                target = Time.new(date.year, date.month, date.day, hour, minute, second, nil)

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