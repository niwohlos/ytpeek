class PingPongPlugin
  def initialize(bot, irc)
    irc.add_subscriber(:on_ping, ->(*args){ on_ping(*args) })
  end

  def on_ping(message, irc, logger)
    message.scan(/(:.+)$/)

    irc.send_message("PONG #{$1}")
  end
end
