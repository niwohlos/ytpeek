class RejoinPlugin < YTPeek::Plugin
  def on_plugin_startup(_, irc)
    @handles[:on_ping] = irc.add_subscriber(:on_ping, ->(*args){ on_ping(*args) })
    @handles[:on_name_reply] = irc.add_subscriber(:on_353, ->(*args){ on_name_reply(*args) })
    @handles[:on_eo_names] = irc.add_subscriber(:on_366, ->(*args){ on_eo_names(*args) })
  end

  def on_plugin_shutdown(_, irc)
    irc.remove_subscriber(:on_ping, @handles.delete(:on_ping))
    irc.remove_subscriber(:on_353, @handles.delete(:on_name_reply))
    irc.remove_subscriber(:on_366, @handles.delete(:on_eo_names))
  end

  def on_ping(_, irc, _)
    @has_joined = false

    irc.send_message("NAMES #{irc.channel}")
  end

  def on_name_reply(message, irc, _)
    match = /^:(\S+)\s+(\S+)\s(\S+)\s+(\S+)\s+(\S+)\s+(?<names>:.*|\S+)/.match(message)
    names = match[:names].split(' ').map { |name| name.gsub(/^[\u0000-\u0040\u007e-\uffff]*/, '') }

    @has_joined = true if names.include?(irc.nick)
  end

  def on_eo_names(_, irc, _)
    irc.send_message("JOIN #{irc.channel}") unless @has_joined
  end
end
