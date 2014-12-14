class QuitPlugin < YTPeek::Plugin
  def on_plugin_shutdown(bot, irc)
    irc.send_message('QUIT :I really have to go now')
  end
end
