class JoinAfterConnectPlugin < YTPeek::Plugin
  def on_plugin_startup(_, irc)
    @handles[:on_eo_motd] = irc.add_subscriber(:on_376, ->(*args){ on_eo_motd(*args) })
  end

  def on_plugin_shutdown(_, irc)
    irc.remove_subscriber(:on_376, @handles.delete(:on_eo_motd))
  end

  def on_eo_motd(_, irc, _)
    irc.send_message("MODE #{irc.nick} +B")

    irc.channels.each do |channel|
      irc.send_message("JOIN #{channel}")
    end
  end
end
