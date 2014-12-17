require 'socket'
require_relative 'logger'

module YTPeek
  class IRC
    attr_reader :server, :channel, :nick, :port

    def initialize(nick, server, channel, options = {})
      @server = server
      @channel = channel
      @nick = nick
      @port = options[:port] || 6667
      @logger = options[:logger] || Logger.new
      @subscribers = {}
    end

    def live
      @connection = TCPSocket.open(@server, @port)

      send_message('USER ' + @nick + ' ' + @nick + ' ' + @nick + ' ' + @nick)
      send_message('NICK ' + @nick)

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
      @logger.info('> ' + message, loggee: self)

      handler = :"on_snd_#{message.scan(/^(?::\S+\s+)?(?<command>\S+)/).first.last.downcase}"

      @logger.debug('@ ' + handler.to_s, loggee: self)

      @subscribers[handler] ||= []
      @subscribers[handler].each do |subscriber|
        return false if subscriber.call(message, self, @logger).eql?(false)
      end

      @connection.puts(message)
    end

    def receive_message()
      message = @connection.gets.strip.force_encoding('UTF-8')

      unless message.valid_encoding?
        @logger.error('! ' + message, loggee: self)

        return true
      end

      @logger.info('< ' + message, loggee: self)

      handler = :"on_rcv_#{message.scan(/^(?::\S+\s+)?(?<command>\S+)/).first.last.downcase}"

      @subscribers[handler] ||= []
      @subscribers[handler].each do |subscriber|
        return false if subscriber.call(message, self, @logger).eql?(false)
      end

      true
    end

    def add_subscriber(type, callback)
      @subscribers[type] ||= []
      @subscribers[type] << callback
      @subscribers[type].last.__id__
    end

    def remove_subscriber(type, handle)
      @subscribers[type] ||= []
      @subscribers[type] = @subscribers[type].reject { |callback| callback.eql?(handle) }
    end
  end
end
