#!/usr/bin/env ruby
# coding: utf-8

require "cgi"
require "socket"
require "net/http"
require "net/https"

require "json"
require "yaml"
require "fileutils"

alias old_puts puts

def puts *x
    y = old_puts x
    $stdout.flush
    return y
end

class Hash
    alias old_method_missing method_missing

    def method_missing *args
        if args.size.eql?(1) && args.first.is_a?(Symbol) && self.has_key?(args.first)
            self[args.first]
        else
            old_method_missing *args
        end
    end
end

class String
    def utf8shorten!(maxlength)
        return self unless bytesize > maxlength

        puts 'shortening'

        while bytesize > maxlength - 6
            chop!
        end

        concat(' […]')
    end

    def utf8shorten(maxlength)
        self.dup.utf8shorten!(maxlength)
    end
end

class TCPSocket
    def connect(host, port, timeout = 30)
        addr = Socket.getaddrinfo(host, nil)
        sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])

        Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
            socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

            begin
                socket.connect_nonblock(sockaddr)
            rescue IO::WaitWritable
                if IO.select(nil, [ socket ], nil, timeout)
                    begin
                        socket.connect_nonblock(sockaddr)
                    rescue Errno::EISCONN
                    rescue
                        socket.close

                        raise
                    end
                else
                    socket.close

                    raise 'Connection timeout'
                end
            end
        end
    end
end

$loaded_plugins = []

$norepost = [ "ponyfac.es", "ragefac.es" ]

$norepost_full_url = [ "wulffmorgenthaler.com", "www.wulffmorgenthaler.com", "xkcd.com", "xkcd.net", "www.xkcd.com", "www.xkcd.net", "www.smbc-comics.com", "www.sarahburrini.de/wordpress", "www.nerfnow.com", "www.vgcats.com/comics",
                       "www.vgcats.com/super", "www.cad-comic.com/cad" ]

$moarhtmlstuff = [ [ "&copy;", "©" ], [ "&nbsp;", " "], [ "&euro;", "€" ], [ "&times;", "×" ], [ "&middot;", "·" ], [ "&bull;", "•" ],
                   [ "&Auml;", "Ä" ], [ "&auml;", "ä"], [ "&Ouml;", "Ö" ], [ "&ouml;", "ö" ], [ "&Uuml;", "Ü" ], [ "&uuml;", "ü" ], [ "&szlig;", "ß" ],
                   [ "&trade;", "™" ] ]

$nazistuff = [ "nazi", "nazis", "fackelzug", "hitler" ]


$http_loop = 0

def http_request(url)
    complete_url = URI.parse(url)

    resp = Net::HTTP.start(complete_url.host, use_ssl: complete_url.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get(complete_url.request_uri)
    end

    case resp
    when Net::HTTPRedirection
        $http_loop += 1
        return [ false, '[ELOOP]' ] if $http_loop > 10
        return http_request(resp['Location'])
    when Net::HTTPSuccess
        $http_loop = 0
        body = resp.body.force_encoding('utf-8')
        if !body.valid_encoding?
            body = resp.body.force_encoding('iso-8859-1').encode('utf-8')
        end
        return [ true, body ]
    else
        $http_loop = 0
        return [ false, "[HTTP-Fehler: #{resp.code} #{resp.message}]" ]
    end
end

def load_data directory
    data = []

    if Dir.exists? directory
        (Dir.entries(directory) - [ ".", ".." ]).each do |file|
            next unless File.file?("#{directory}/#{file}")

            source = File.read("#{directory}/#{file}").force_encoding(Encoding::UTF_8)

            data << eval(source, $binding)
        end
    end

    data
end

class IRC
    attr_reader :src, :chan, :nick, :port, :has_op, :has_joined, :plugins
    attr_accessor :con

    def initialize(nick, channel, server = "irc.euirc.net", port = 6667)
        $binding = Kernel.binding
        @srv = server
        @chan = channel
        @nick = nick
        @port = port
        @has_op = false
        @has_joined = true

        @matches = load_data "matches"
        @plugins = load_data "plugins"
        @commands = Array.new

        dependencies_satisfied = true

        @plugins.delete_if do |plugin|
            !plugin.enabled
        end

        # probably should construct a dependency graph for startup order
        @plugins.each do |plugin|
            $loaded_plugins << plugin.name

            plugin.dependencies.each do |dependency|
                unless @plugins.any?{ |plugin| plugin.name.eql? dependency }
                    puts "Plugins: %s depends on %s, which is either not enabled or present!" % [ plugin.name, dependency ]

                    dependencies_satisfied = false
                end
            end
        end

        exit 0 unless dependencies_satisfied

        @plugins.each do |plugin|
            plugin.startup.call plugin.name, self

            @commands += load_data("plugins/#{plugin.name}/commands")
        end

        @commands = Hash[%i{channelonly always}.zip(@commands.partition do |command|
            command.channelonly
        end)]

        @target = nil
        @source = nil
    end
    def send(msg)
        puts("<- " + msg)
        @con.send(msg + "\n", 0)
	sleep(0.4)
    end
    def inject(msg)
        @con.ungetbyte(msg + "\n")
        send("PING #{@nick}")
    end
    def read
        msg = @con.gets().strip.force_encoding("utf-8")

        if !msg.valid_encoding?
            puts("-> INV " + msg)
            return true
        end

        puts("-> " + msg)

        case msg
        when /^PING\s(.+)$/i
            match = /^PING\s+(.+)$/.match(msg)
            send("PONG " + match[1])

            @has_joined = false

            send("NAMES " + @chan)
        when /^:\S+\s+\S+/
            match = /^:(\S+)\s+(\S+)/.match(msg)
            src = match[1]
            type = match[2].upcase
            case type
            when "376" # End of MOTD
                send("MODE " + @nick + " +B")
                send("JOIN " + @chan)
            when "353" # RPL_NAMREPLY
                #          src     type    dest    msg
                match = /^:(\S+)\s+(\S+)\s(\S+)\s+(\S+)\s+(\S+)\s+(:.*|\S+)/.match(msg)
                unless match[6].index(@nick).eql? nil
                    @has_joined = true
                end
            when "366" # RPL_ENDOFNAMES
                unless @has_joined
                   send("JOIN " + @chan)
                end
            when "PRIVMSG"
                #          src     type    dest    msg
                match = /^:(\S+)\s+(\S+)\s+(\S+)\s+(:.*|\S+)/.match(msg)

                msg = match[4].strip.encode("utf-8")
                msg = msg[1..-1] if msg[0] == ":"
                msg.strip!

                inmatch = /^([^!]+)/.match(match[1])
                src = inmatch[1] if inmatch

                pipe = match[3]
                if pipe.downcase == @nick.downcase
                    pipe = src
                end

                @source = src
                @target = pipe
                inchn = (pipe == @chan)

                if msg.downcase == "!help"
                    send("PRIVMSG %s :Ein bloatiger YT-Link-Warner" % pipe)
                    @plugins.each do |plugin|
                        plugin.help.each  do |help|
                            send("PRIVMSG %s :#{help}" % pipe)
                        end
                    end
                    send("PRIVMSG %s :!is_rp [url] – Wurde die URL schonmal gepostet?" % pipe)

                    return true
                end

                rp_match = /^!is_rp\s+(https?:\/\/|)(\S+)/i.match(msg)
                if rp_match
                    ytmi = 1
                    ytm = /www\.youtube\.com\/watch\?((\w+=[\w-]+&)*)v=([\w-]+)/.match(rp_match[2])
                    ytmi = 3 if ytm
                    ytm = /youtu\.be\/([\w-]+)/.match(rp_match[2]) if !ytm
                    ytm = /www\.youtube\.com\/v\/([\w-]+)/.match(rp_match[2]) if !ytm

                    if !ytm
                        url = rp_match[2].downcase.chomp("/")
                    else
                        url = ytm[ytmi]
                    end
                    entry = $urls[url]

                    if entry
                        diff = Time.new - entry[1]
                        send("PRIVMSG %s :REPOST!!1!elf, OP: %s (vor %i d %s) von %s" % [ pipe, entry[1].strftime("am %d.%m.%Y um %T"), (diff / 86400).to_i, Time.at(diff).getutc.strftime("%T"), entry[0] ])
                    else
                        send("PRIVMSG %s :That ain't no repost, mate. Feel free to post it." % pipe)
                    end

                    msg = msg[6..-1].strip;
                end

                @commands.always.each do |command|
                    test = command.pattern.match(msg)
                    if test
                        command.command.call test
                    end
                end

                if inchn
                    @commands.channelonly.each do |command|
                        test = command.pattern.match(msg)
                        if test
                            command.command.call test
                        end
                    end

                    url_match = /https?:\/\/([^\s(),]+)/i.match(msg)

                    if url_match
                        dwn = msg.downcase

                        for url in $norepost
                            if dwn.include?(url)
                                url_match = nil
                                break
                            end
                        end

                        if url_match
                            for url in $norepost_full_url
                                if url_match[1] == url
                                    url_match = nil
                                    break
                                end
                            end
                        end
                    end

                    if url_match
                        ytmi = 1
                        ytm = /www\.youtube\.com\/watch\?((\w+=[\w-]+&)*)v=([\w-]+)/.match(msg)
                        ytmi = 3 if ytm
                        ytm = /youtu\.be\/([\w-]+)/.match(msg) if !ytm
                        ytm = /www\.youtube\.com\/v\/([\w-]+)/.match(msg) if !ytm

                        if !ytm
                            url = url_match[1].downcase.chomp("/")
                        else
                            url = ytm[ytmi]
                        end
                        entry = $urls[url]

                        if entry
                            #if !dwn.include?("inb4 repost") && !dwn.include?("drin bevor repost") && !dwn.include?("drin bevor hatten wir schon") && !dwn.include?("mfw")
                            #    diff = Time.new - entry[1]
                            #    send("PRIVMSG %s :REPOST!!1!elf (OP: %s (vor %i d %s) von %s)" % [ @chan, entry[1].strftime("am %d.%m.%Y um %T"), (diff / 86400).to_i, Time.at(diff).getutc.strftime("%T"), entry[0] ])
                            #end
                        else
                            $urls[url] = [ src, Time.new ]
                        end
                    end

                    for rules in @matches
                        for rule in rules
                            for resource in rule.resources
                                um = resource.pattern.match(msg)
                                if um
                                    match_url = (rule.cleanurl + (rule.cleanurl.include?('<match>') ? '' : '<match>')).gsub('<match>', um[resource.group])
                                    incoming = http_request match_url

                                    if !incoming[0]
                                        send("PRIVMSG #{@chan} :#{src} ist heute für einen #{incoming[1]} verantwortlich.")
                                        break
                                    end


                                    title = nil


                                    if rule.title.pattern.kind_of?(Array)
                                        matches = rule.title.pattern.map { |m| m.match(incoming[1]) }
                                        if !matches.include?(nil)
                                            title = eval(rule.title.group)
                                        end
                                    else
                                        title_match = rule.title.pattern.match(incoming[1])
                                        if title_match
                                            if rule.title.group.kind_of?(Integer)
                                                title = title_match[rule.title.group]
                                            else
                                                title = eval(rule.title.group)
                                            end
                                        end
                                    end

                                    if title
                                        title = title.gsub(/<br[^>]*>/, "⁋")
                                                     .gsub(/<[^>]*>/, '')

                                        title = CGI.unescapeHTML(title)

                                        for char in $moarhtmlstuff
                                            title.gsub!(char[0], char[1])
                                        end


                                        title = title.strip
                                                     .gsub(/\s+/, " ")
                                                     .gsub(/⁋⁋+/, "⁋")
                                                     .sub(/^⁋/, "")
                                                     .sub(/⁋$/, "")

                                        for appendix in rule.remove
                                            if appendix.respond_to? :call
                                                title = appendix.call title, match_url
                                            else
                                                title.gsub!(appendix, "")
                                            end
                                        end

                                        break if title == ""

                                        title = "Just a prank, bro" if /\brickroll\b/i.match(title)
                                        title = "Just a prank, bro" if /\bnever gonna give you up\b/i.match(title)

                                        if ['alexander', 'akluth', 'derhartmut'].include?(src.downcase)
                                            full_msg_wo_end_quote = "PRIVMSG #{@chan} :Der alte Lustmolch #{src} präsentiert Ihnen heute (Taschentücher bereithalten): „#{title}"
                                        else
                                            full_msg_wo_end_quote = "PRIVMSG #{@chan} :#{src} präsentiert Ihnen heute: „#{title}"
                                        end

                                        # If the message needs to be shortened, the '“' should not be stripped but
                                        # instead follow the '[…]'; therefore, it is added here after shortening the
                                        # message appropriately.
                                        send(full_msg_wo_end_quote.utf8shorten(443) + '“')
                                    end

                                    escape = true

                                    break if escape
                                end

                                break if escape
                            end

                            break if escape
                        end
                    end

                    if url_match
                        result = nil

                        begin
                            tagger = TCPSocket.new('xanclic.moe', 1112, 10)
                        rescue
                            tagger = nil
                        end
                        if tagger
                            tagger.puts(url_match[0])
                            begin
                                result = tagger.readline()
                            rescue
                                result = nil
                            end

                            tagger.close()
                        end

                        if result
                            begin
                                result = JSON.parse(result)
                                result = result[0]

                                result['rating'] = Hash[result['rating']]

                                result['character'] = [] unless result['character']
                                result['copyright'] = [] unless result['copyright']
                                result['general'] = [] unless result['general']
                            rescue
                                result = nil
                            end
                        end

                        if result
                            rating = '%.1f %% SFW, %.1f %% explicit' % [result['rating']['safe'] * 100.0,
                                                                        result['rating']['explicit'] * 100.0]

                            if result['character'][0] && result['copyright'][0]
                                sauce = '%s (%.1f %%) from %s (%.1f %%)' % [result['character'][0][0],
                                                                            result['character'][0][1] * 100.0,
                                                                            result['copyright'][0][0],
                                                                            result['copyright'][0][1] * 100.0]
                            elsif result['copyright'][0]
                                sauce = 'from %s (%.1f %%)' % [result['copyright'][0][0],
                                                               result['copyright'][0][1] * 100.0]
                            elsif result['character'][0]
                                sauce = '%s (%.1f %%)' % [result['character'][0][0],
                                                          result['character'][0][1] * 100.0]
                            else
                                sauce = nil
                            end
                            saucestr = sauce ? "; #{sauce}" : ''

                            tags = result['general'][0..4].map { |tag|
                                '%s (%.1f %%)' % [tag[0], tag[1] * 100.0]
                            } * ', '

                            send("PRIVMSG #{@chan} :#{tags}#{saucestr} (#{rating})")
                        end
                    end
                end
            end
        end
        return true
    end
    def connect()
        @con = TCPSocket.open(@srv, @port)
        send("USER " + @nick + " " + @nick + " " + @nick + " " + @nick)
        send("NICK " + @nick)
    end
    def loop()
        begin
            while true do
                ready = select([@con], nil, nil, nil)

                next if !ready

                for fd in ready[0] do
                    case fd
                    when @con then
                        return if @con.eof
                        return if !read()
                    end
                end
            end
        rescue Interrupt
            t = Thread.new do
                puts("\nShutting down, writing data to .rubybot...")
                File.open(".rubybot", "w") { |f|
                f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
                }
                puts("Shutting down plugins...")
                @plugins.each do |plugin|
                    next unless $loaded_plugins.include? plugin.name
                    plugin.shutdown.call plugin.name, self
                end
                puts("Done, exiting.")
                exit 0
            end

            t.join
        end
    end
end

if Signal.list.include? "HUP"
    trap "HUP" do
        Thread.new do
            puts("\nShutting down, writing data to .rubybot...")
            File.open(".rubybot", "w") { |f|
                f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
            }
            plugins = load_data "plugins"
            puts("Shutting down plugins...")
            plugins.each do |plugin|
                next unless $loaded_plugins.include? plugin.name
                plugin.shutdown.call plugin.name, self
            end
            puts("Done, exiting.")
            exit 0
        end
    end
end

trap "TERM" do
    Thread.new do
        puts("\nShutting down, writing data to .rubybot...")
        File.open(".rubybot", "w") { |f|
            f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
        }
        plugins = load_data "plugins"
        puts("Shutting down plugins...")
        plugins.each do |plugin|
            next unless $loaded_plugins.include? plugin.name
            plugin.shutdown.call plugin.name, self
        end
        puts("Done, exiting.")
        exit 0
    end
end

$karmas = nil
$watt   = nil
$wfw    = nil # watt from who
$urls   = nil

if File::exists?(".rubybot")
    settings = YAML::load_file(".rubybot")
    $karmas = settings["karmas"]
    $watt   = settings["watt"  ]
    $wfw    = settings["wfw"   ]
    $urls   = settings["urls"  ]
end

$karmas = Hash.new if !$karmas
$watt   = Hash.new if !$watt
$wfw    = Hash.new if !$wfw
$urls   = Hash.new if !$urls

$last_incer = Hash.new
$last_decer = Hash.new


irc = IRC.new("ytpeek", "#niwohlos", "irc.nbg.de.euirc.net")
irc.connect()
irc.loop()
