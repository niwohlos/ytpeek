require_relative 'plugin'

module YTPeek
    class PluginManager
        def self.load_plugins(bot, irc)
            Dir.glob('plugins/**/*.rb').map do |plugin|
                load(plugin)

                name = File.basename(plugin, '.rb').split('_').map { |name| name.capitalize }.join

                const_get(name).new(bot, irc)
            end
        end
    end
end
