require_relative 'plugin'
require_relative 'command'

module YTPeek
    class PluginManager
        def self.load_plugins(bot, irc)
            Dir.glob(File.dirname(__FILE__) + '/plugins/**/*.rb').map do |plugin_name|
                load(plugin_name)

                name = File.basename(plugin_name, '.rb').split('_').map { |name| name.capitalize }.join.+('Plugin')

                plugin = const_get(name).new
                plugin.on_plugin_startup(bot, irc)

                plugin
            end
        end

        def self.unload_plugins(bot, irc, plugins)
            plugins.each do |plugin|
                plugin.on_plugin_shutdown(bot, irc)
            end
        end

        def self.find_plugins()
            path = "../gems/*/gems/*/lib/ytpeek/plugin/*"

            files = []
            $LOAD_PATH.each do |load_path|
                globbed = Dir["#{File.expand_path path, load_path}#{Gem.suffix_pattern}"]

                globbed.each do |load_path_file|
                    files << load_path_file if File.file?(load_path_file.untaint)
                end
            end

            File.basename(files)
        end
    end
end
