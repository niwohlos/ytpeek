require_relative 'plugin'

module YTPeek
  class Command < Plugin
    def on_plugin_startup(bot, irc)
      @handles[:on_privmsg] = irc.add_subscriber(:on_privmsg, ->(*args){ on_privmsg(*args) })
    end

    def on_plugin_shutdown(_, irc)
      irc.remove_subscriber(:on_privmsg, @handles.delete(:on_privmsg))
    end

    def on_privmsg(message, irc, logger)
      match_message = /^:(?<source>\S+)\s+(?<type>\S+)\s+(?<destination>\S+)\s+(?<message>:.*|\S+)/.match(message)

      message = match_message[:message].strip.encode('UTF-8').strip
      message = message[1..-1] if message.start_with?(':')

      match_source = /^(?<source>[^!]+)/.match(match_message[:source])

      return unless match_source

      source = match_source[:source]
      destination = match_message[:destination]
      destination = source if destination.downcase == irc.nick.downcase

      on_command_message(message, source, destination, irc, logger)
    end

    def on_command_help
      []
    end

    def on_command_message(_, _, _, _, _)
      raise StandardError, 'Not implemented'
    end
  end
end
