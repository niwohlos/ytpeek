class HelpPlugin < YTPeek::Command
  def on_plugin_startup(bot, _)
    @bot = bot

    super
  end

  def on_command_message(message, _, destination, irc, _)
    return unless message.eql?('!help')

    help_texts = [ 'Ein bloatiger YT-Link-Warner' ]

    @bot.plugins.each do |plugin|
      help_texts = [*help_texts + plugin.on_command_help] if plugin.kind_of?(YTPeek::Command)
    end

    help_texts.each do |help_text|
      irc.send_message('PRIVMSG %s :%s' % [ destination, help_text ])

      sleep(0.4)
    end
  end
end
