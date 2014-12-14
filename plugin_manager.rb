require_relative 'plugin'

module YTPeek
    class PluginManager
        def self.load_plugins(bot, irc)
            Dir.glob('plugins/**/*.rb').map do |plugin_name|
                load(plugin_name)

                name = File.basename(plugin_name, '.rb').split('_').map { |name| name.capitalize }.join.+('Plugin')

                plugin = const_get(name).new
                plugin.on_plugin_startup(bot, irc)
            end
        end

        def self.unload_plugins(bot, irc, plugins)
            plugins.each do |plugin|
                plugin.on_plugin_shutdown.call(bot, irc)
            end
        end
    end
end
