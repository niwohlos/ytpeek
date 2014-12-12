require 'yaml'
require_relative 'irc'
# require_relative 'plugin'
require_relative 'plugin_manager'

module YTPeek
  class Bot
    def initialize(username, server, channels = [])
      @storage = {}
      @irc = IRC.new(username, server, channels: channels)
      @plugins = PluginManager.load_plugins(self, @irc)

      if File::exists?(".rubybot")
        @storage = YAML::load_file(".rubybot")
      end

      trap('HUP') { on_shutdown() } if Signal.list.include?('HUP')
      trap('TERM') { on_shutdown() }
      trap('KILL') { on_shutdown() }

      begin
        @irc.live()
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

          puts('Shutting down plugins...')

          PluginManager.unload_plugins(self, @irc, @plugins)

          puts('Done, exiting.')

          exit 0
        end
      end.join
    end
  end
end
