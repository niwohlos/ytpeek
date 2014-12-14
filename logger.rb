module YTPeek
  class Logger
    %i[ debug info notice warning error critical alert emergency ].each do |type|
      define_method type do |message, context = {}|
        log(type, message, context)
      end
    end

    def log(type, message, context = { loggee: nil })
      loggee = context.delete(:loggee).class.to_s.split('::').last.downcase << '.'
      loggee = 'app.' if loggee.eql?('nilclass.')

      context.each_pair do |key, value|
        message.gsub!(/\{#{key}\}/, value)
      end

      processed_message = "#{loggee}#{type.upcase}" << (' :' unless loggee.eql?('irc.')).to_s << " #{message}"

      case type
        when :warning
        when :error
        when :critical
        when :alert
        when :emergency
          warn processed_message
        else
          puts processed_message
      end
    end
  end
end
