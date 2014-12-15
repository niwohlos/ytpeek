require 'fileutils'

class KarmaPlugin < YTPeek::Command
  def on_plugin_startup(bot, irc)
    @storage = bot.storage
    @storage[:karmas] = Hash.new(0).merge(@storage[:karmas])
    @storage[:karmas_increment] = {}
    @storage[:karmas_decrement] = {}

    super(bot, irc)
  end

  def on_plugin_shutdown(bot, irc)
    @storage.delete(:karmas_increment)
    @storage.delete(:karmas_decrement)

    super(bot, irc)
  end

  def on_command_help
    [
      "!karma [x] – Wie ist [x]?",
      "[x]++, [x]-- – So ist [x]!",
    ]
  end

  def on_command_message(message, source, destination, irc, logger)
    case message
      when /^!karma\s+(?<topic>\S+)/
      karma = @storage[:karmas][$~[:topic].downcase]

      irc.send_message('PRIVMSG %s :%s hat Karma %i' % [ destination, $~[:topic], karma ])
    when /^(?<topic>[[:word:]♥+-]+)(?<action>\+\+|--)(?:$|\s)/
      topic = $~[:topic].downcase

      if source && (topic == source.downcase)
        irc.send_message('PRIVMSG %s :Wage es ja nicht, %s...' % [ irc.channel, source ])
      else
        if $~[:action].eql?('++')
          if @storage[:nazistuff] && @storage[:nazistuff].include?(topic)
            irc.send_message('MODE %s -Q' % [ irc.channel ])
            irc.send_message('KICK %s %s :nazi' % [ irc.channel, source ])
            irc.send_message('MODE %s +Q' % [ irc.channel ])
          elsif @storage[:karmas_increment][topic] && (@storage[:karmas_increment][topic][:source] == source.downcase) && (Time.new - @storage[:karmas_increment][topic][:time] < 600)
            irc.send_message('PRIVMSG %s :%s: Och nö, nicht schon wieder...' % [ irc.channel, source ])
          else
            @storage[:karmas][topic] += 1
            @storage[:karmas_increment][topic] = { source: source.downcase, time: Time.new }
          end
        else
          if @storage[:karmas_decrement][topic] && (@storage[:karmas_decrement][topic][:source] == source.downcase) && (Time.new - @storage[:karmas_decrement][topic][:time] < 600)
            irc.send_message('PRIVMSG %s :%s: Och nö, nicht schon wieder...' % [ irc.channel, source ])
          else
            @storage[:karmas][topic] -= 1
            @storage[:karmas_decrement][topic] = { source: source.downcase, time: Time.new }
          end
        end
      end
    end
  end
end
