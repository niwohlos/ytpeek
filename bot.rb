require 'yaml'
require_relative 'irc'
# require_relative 'plugin'
require_relative 'plugin_manager'

module YTPeek
  class Bot
    def initialize(username, server, channels = [])
      @storage = {}

      if File::exists?(".rubybot")
        @storage = YAML::load_file(".rubybot")
      end

      trap('HUP') { on_shutdown() } if Signal.list.include?('HUP')
      trap('TERM') { on_shutdown() }
      trap('KILL') { on_shutdown() }

      begin
        irc = IRC.new(username, server, channels: channels)

        p plugins = PluginManager.load_plugins(self, irc)

        irc.live()
      rescue Interrupt
        on_shutdown()
      end
    end

    def on_shutdown
      Thread.new do
        puts()
        puts('Shutting down, writing data to .rubybot...')

        File.open('.rubybot', 'w') do |f|
          f.write(@storage.to_yaml)

          plugins = load_data('plugins')
          puts('Shutting down plugins...')
          plugins.each do |plugin|
            next unless $loaded_plugins.include?(plugin.name)
            plugin.shutdown.call(plugin.name, self)
          end
          puts('Done, exiting.')
          exit 0
        end
      end.join
    end
  end
end
