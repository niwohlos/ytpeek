class NaziStuffPlugin < YTPeek::Plugin
  def on_plugin_startup(bot, _)
    bot.storage[:nazistuff] = [ "nazi", "nazis", "fackelzug", "hitler" ]
  end

  def on_plugin_shutdown(bot, _)
    bot.storage.delete(:nazistuff)
  end
end
