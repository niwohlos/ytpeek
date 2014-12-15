class BackwardsStoragePlugin < YTPeek::Plugin
  def on_plugin_startup(bot, _)
    bot.storage.keys.each do |key|
      bot.storage[key.to_sym] = bot.storage.delete(key) unless key.is_a?(Symbol)
    end
  end
end
