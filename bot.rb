require 'yaml'
require_relative 'irc'
# require_relative 'plugin'
require_relative 'plugin_manager'

module YTPeek
  class Bot
    attr_reader :storage

    def initialize(username, server, channel)
      @storage = YAML::load_file(".rubybot") rescue {} # load first
      @irc = IRC.new(username, server, channel)
      @plugins = PluginManager.load_plugins(self, @irc)

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
