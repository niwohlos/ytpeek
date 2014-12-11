require 'yaml'
require_relative 'irc'
# require_relative 'plugin'
require_relative 'plugin_manager'

module YTPeek
  class Bot
    def initialize(username, server, channels = [])
      if File::exists?(".rubybot")
        settings = YAML::load_file(".rubybot")
        $karmas = settings["karmas"]
        $watt   = settings["watt"  ]
        $wfw    = settings["wfw"   ]
        $urls   = settings["urls"  ]
      end

      $karmas ||= Hash.new
      $watt   ||= Hash.new
      $wfw    ||= Hash.new
      $urls   ||= Hash.new

      $last_incer = Hash.new
      $last_decer = Hash.new

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
          f.write({
            karmas: $karmas,
            watt: $watt,
            wfw: $wfw,
            urls: $urls
          }.to_yaml)

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
