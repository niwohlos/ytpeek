class QuitPlugin < YTPeek::Plugin
  def on_plugin_shutdown(_, irc)
    irc.send_message('QUIT :I really have to go now')
  end
end
