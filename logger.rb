class Logger
  %i[ debug info notice warning error critical alert emergency ].each do |type|
    define_method type do |message, context = {}|
      log(type, message, context)
    end
  end

  def log(type, message, context = {})
    return unless message.is_a? String

    context.each_pair do |key, value|
      message.gsub!(/\{#{key}\}/, value)
    end

    case type
      when :warning
      when :error
      when :critical
      when :alert
      when :emergency
        warn "#{type.upcase} #{message}"
      else
        puts "#{type.upcase} #{message}"
    end
  end
end
