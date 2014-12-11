require 'socket'
require_relative 'logger'

module YTPeek
  class IRC
    attr_reader :server, :channel, :nick, :port

    def initialize(nick, server = "irc.euirc.net", options = {})
      @server = server
      @channels = options[:channels] || []
      @nick = nick
      @port = options[:port] || 6667
      @logger = options[:logger] || Logger.new
      @subscribers = {}
    end

    def live
      @connection = TCPSocket.open(@server, @port)

      send_message("USER " + @nick + " " + @nick + " " + @nick + " " + @nick)
      send_message("NICK " + @nick)

      while true do
        next unless (sockets = select([@connection], nil, nil, nil))

        sockets.first.each do |socket|
          if socket.eql?(@connection)
              return if @connection.eof
              return unless receive_message
          end
        end
      end
    end

    def send_message(message)
      @logger.info('-> ' + message)
      @connection.puts(message + "\n", 0)
    end

    def receive_message()
      message = @connection.gets.strip.force_encoding("utf-8")

      unless message.valid_encoding?
        @logger.error('<! ' + message)

        return true
      end

      @logger.info('<- ' + message)

      handler = :"on_#{message[/^\S+/].downcase}"

      @subscribers[handler] ||= []
      @subscribers[handler].each do |subscriber|
        return false if subscriber.call(message, self, @logger).eql?(false)
      end

      true
    end

    def add_subscriber(type, callback)
      @subscribers[type] ||= []
      @subscribers[type] << callback
    end
  end
end
