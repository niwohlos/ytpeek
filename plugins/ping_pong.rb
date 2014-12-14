class PingPongPlugin < YTPeek::Plugin
  def on_plugin_startup(bot, irc)
    @handles[:on_ping] = irc.add_subscriber(:on_ping, ->(*args){ on_ping(*args) })
  end

  def on_plugin_shutdown(bot, irc)
    irc.remove_subscriber(@handles.delete(:on_ping))
  end

  def on_ping(message, irc, logger)
    message.scan(/(:.+)$/)

    logger.debug('received ping "{payload}"', loggee: self, payload: $1)

    irc.send_message("PONG #{$1}")
  end
end
