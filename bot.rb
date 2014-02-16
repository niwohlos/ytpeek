#!/usr/bin/env ruby
# coding: utf-8

require "cgi"
require "socket"
require "net/http"
require "net/https"

require "json"
require "yaml"

alias old_puts puts
def puts *x
    y = old_puts x
    $stdout.flush
    return y
end

$matches = [ [ /www\.youtube\.com\/watch\?((\w+=[\w-]+&)*)v=([\w-]+)/, 3, "http://www.youtube.com/watch?v=", /<title>(.*)<\/title>/im, 1, [ " - YouTube" ] ],
             [ /youtu\.be\/([\w-]+)/, 1, "http://www.youtube.com/watch?v=", /<title>(.*)<\/title>/im, 1, [ " - YouTube" ] ],
             [ /y2u\.be\/([\w-]+)/, 1, "http://www.youtube.com/watch?v=", /<title>(.*)<\/title>/im, 1, [ " - YouTube" ] ],
             [ /www\.youtube\.com\/v\/([\w-]+)/, 1, "http://www.youtube.com/watch?v=", /<title>(.*)<\/title>/im, 1, [ " - YouTube" ] ],
             [ /i\.imgur\.com\/(\w+)\./, 1, "http://imgur.com/", /<title>(.*)<\/title>/im, 1, [ " - Imgur", "imgur: the simple image sharer", "imgur: the simple 404 page", "imgur: the simple overloaded page" ] ],
             [ /imgur\.com\/(gallery\/)?(\w+)\b/, 2, "http://imgur.com/", /<title>(.*)<\/title>/im, 1, [ " - Imgur", "imgur: the simple image sharer", "imgur: the simple 404 page", "imgur: the simple overloaded page" ] ],
             [ /forum\.lowlevel\.eu\/index.php\?([^\s,]+)/, 1, "http://forum.lowlevel.eu/index.php?", /<title>(.*)<\/title>/im, 1, [ ] ],
             [ /forum\.osdev\.org\/viewtopic.php\?([^\s,]+)/, 1, "http://forum.osdev.org/viewtopic.php?", /<title>(.*)<\/title>/im, 1, [ "OSDev.org • View topic - " ] ],
             [ /tud\.hicknhack\.org\/forum\/messages\/(\d+)/, 1, "http://tud.hicknhack.org/forum/messages/", /<div class="head">([^<]*)/i, 1, [ ] ],
             [ /boards\.4chan\.org\/((\w+)\/res\/\d+)#p(\d+)/, 1, "http://boards.4chan.org/<match>.json", [ /.*/m ], 'post = JSON.parse(matches[0][0])["posts"].select { |p| p["no"].to_i == um[3].to_i }[0]; if post; content = "[#{Time.at(post["time"].to_i).strftime("%T")}] #{unless post["com"].nil?; post["com"].gsub(/<br.*$/, " […]"); else; ""; end}"; if post["tim"]; content + " (http://images.4chan.org/#{um[2]}/src/#{post["tim"]}#{post["ext"]})"; else; content; end; else "[Post im Thread nicht gefunden]"; end', [ ] ],
             [ /boards\.4chan\.org\/((\w+)\/res\/\d+)/, 1, "http://boards.4chan.org/<match>.json", [ /.*/m ], 'op = JSON.parse(matches[0][0])["posts"][0]; "[#{Time.at(op["time"].to_i).strftime("%T")}] #{unless op["sub"].nil? || op["sub"].empty?; op["sub"]; else; unless op["com"].nil?; op["com"].gsub(/<br.*$/, " […]"); else; ""; end; end} (http://images.4chan.org/#{um[2]}/src/#{op["tim"]}#{op["ext"]})"', [ ] ],
             [ /9gag\.com\/gag\/(\d+)/, 1, "http://9gag.com/gag/", /<title>(.*)<\/title>/im, 1, [ "9GAG - " ] ],
             [ /golem\.de\/(\d+\/[\d-]+\.html)/, 1, "http://www.golem.de/", /<title>(.*)<\/title>/im, 1, [ " - Golem.de" ] ],
             [ /sukebei\.nyaa\.eu\/\?page=torrentinfo&tid=(\d+)/, 1, "http://sukebei.nyaa.eu/?page=torrentinfo&tid=", /<td\ class="tinfotorrentname">([^<]*)<\/td>/, 1, [ ] ],
             [ /sukebei\.nyaa\.eu\/\?page=download&tid=(\d+)/, 1, "http://sukebei.nyaa.eu/?page=torrentinfo&tid=", /<td\ class="tinfotorrentname">([^<]*)<\/td>/, 1, [ ] ],
             [ /nyaa\.eu\/\?page=torrentinfo&tid=(\d+)/, 1, "http://www.nyaa.eu/?page=torrentinfo&tid=", /<td\ class="tinfotorrentname">([^<]*)<\/td>/, 1, [ ] ],
             [ /nyaa\.eu\/\?page=download&tid=(\d+)/, 1, "http://www.nyaa.eu/?page=torrentinfo&tid=", /<td\ class="tinfotorrentname">([^<]*)<\/td>/, 1, [ ] ],
             [ /store\.steampowered\.com\/app\/(\d+)/, 1, "http://store.steampowered.com/app/<match>/?cc=us", /<title>(.*)<\/title>/im, 1, [ " on Steam"] ],
             [ /(?=\d{3}-\d{1,5}-\d{1,7}-\d{1,7}-\d)(\A[0-9-]{17}\z)/, 2, "http://www.isbnsearch.org/isbn/", /<h2>([^<]*)<\/h2>/, 1, [ ] ],
             [ /twitter\.com\/(\w+\/status\/\d+)/, 1, "https://twitter.com/", [ /<p\s+class="[^"]*tweet-text[^"]*">(([^<]*|<[^\/]|<\/[^p])*)<\/p>/, /<span\s+class="[^"]*_timestamp[^"]*"\s+data-time="(\d+)"/, /<span>&rlm;<\/span><span\s+class="[^"]*username[^"]*"[^>]*><s>([^<]*)<\/s><b>([^<]*)</ ], '"[#{if Time.at(matches[1][1].to_i).strftime(\'%F\') == Time.new.strftime(\'%F\'); Time.at(matches[1][1].to_i).strftime(\'%T\'); else; Time.at(matches[1][1].to_i).strftime(\'%A, %-d. %B %Y] [%T\'); end}] &lt;#{matches[2][1]}#{matches[2][2]}&gt; #{matches[0][1]}"', [ ] ],
             [ /www\.henkessoft300\.de/, 1, "http://www.henkessoft3000.de", /<title>(.*)<\/title>/im, 1, [ " lol henkes content is best content!" ] ] ]

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

class IRC
    def initialize(nick, channel, server = "irc.euirc.net", port = 6667)
        @srv = server
        @chan = channel
        @nick = nick
        @port = port
        @has_op = false
        @has_joined = true
    end
    def send(msg)
        puts("<- " + msg)
        @con.send(msg + "\n", 0)
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

                inchn = (pipe == @chan)

                if msg.downcase == "!help"
                    send("PRIVMSG %s :Ein bloatiger YT-Link-Warner" % pipe)
                    send("PRIVMSG %s :?? [x] – Was ist [x]?" % pipe)
                    send("PRIVMSG %s :?! [x] – Das ist [x]!" % pipe)
                    send("PRIVMSG %s :!karma [x] – Wie ist [x]?" % pipe)
                    send("PRIVMSG %s :[x]++, [x]-- – So ist [x]!" % pipe)
                    send("PRIVMSG %s :!pdp – Wie und was ist irgendwas" % pipe)
                    send("PRIVMSG %s :!wtfids [x] – Wie und was ist das" % pipe)
                    send("PRIVMSG %s :!is_rp [url] – Wurde die URL schonmal gepostet?" % pipe)

                    return true
                end

                watt_match = /^\?\?\s*([[:word:]♥+-]+)$/.match(msg)
                if watt_match
                    desc = $watt[watt_match[1].downcase]
                    who = $wfw[watt_match[1].downcase]
                    while desc && (desc[0] == "ref")
                        who = $wfw[desc[1]]
                        desc = $watt[desc[1]]
                    end
                    if desc
                        if who
                            send("PRIVMSG %s :%s: „%s“ (von %s)" % [ pipe, watt_match[1], desc, who ]) if desc
                        else
                            send("PRIVMSG %s :%s: „%s“" % [ pipe, watt_match[1], desc ]) if desc
                        end
                    end
                end

                karma_req_match = /^!karma\s+([[:word:]♥+-]+)$/.match(msg)
                if karma_req_match || (msg == "!karma")
                    if karma_req_match
                        resp = karma_req_match[1]
                    else
                        resp = src
                    end
                    karma = $karmas[resp.downcase]
                    karma = 0 if !karma
                    send("PRIVMSG %s :%s hat Karma %i" % [ pipe, resp, karma ])
                end

                wtf_match = /^!wtfids\s+([[:word:]♥+-]+)$/.match(msg)
                if msg == "!pdp" || wtf_match
                    if wtf_match
                        entry = wtf_match[1].downcase
                        entry = [ entry, $watt[entry] ]
                    else
                        entry = $watt.to_a[rand($watt.size)]
                    end

                    karma = $karmas[entry[0]]
                    karma = 0 if !karma

                    desc = $watt[entry[0]]
                    who = $wfw[entry[0]]
                    while desc && (desc[0] == "ref")
                        who = $wfw[desc[1]]
                        desc = $watt[desc[1]]
                    end

                    if desc
                        if who
                            send("PRIVMSG %s :%s (%s: „%s“) hat Karma %i" % [ pipe, entry[0], who, desc, karma ])
                        elsif entry[1]
                            send("PRIVMSG %s :%s („%s“) hat Karma %i" % [ pipe, entry[0], desc, karma ])
                        else
                            send("PRIVMSG %s :%s (keine Beschreibung) hat Karma %i" % [ pipe, entry[0], karma ])
                        end
                    end
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

                if inchn
                    karma_match = /^([[:word:]♥+-]+)(\+\+|--)$/.match(msg)
                    if karma_match
                        who = karma_match[1].downcase
                        if src && (who == src.downcase)
                            send("PRIVMSG %s :Wage es ja nicht, %s..." % [ @chan, inmatch ])
                        else
                            $karmas[who] = 0 if !$karmas[who]

                            if karma_match[2] == "++"
                                if $nazistuff.include?(who)
                                    send("MODE %s -Q" % [ @chan ])
                                    send("KICK %s %s :nazi" % [ @chan, inmatch ])
                                    send("MODE %s +Q" % [ @chan ])
                                elsif $last_incer[who] && ($last_incer[who][0] == src.downcase) && (Time.new - $last_incer[who][1] < 600)
                                    send("PRIVMSG %s :%s: Och nö, nicht schon wieder..." % [ @chan, src ])
                                else
                                    $karmas[who] += 1
                                    $last_incer[who] = [ src.downcase, Time.new ]
                                end
                            else
                                if $last_decer[who] && ($last_decer[who][0] == src.downcase) && (Time.new - $last_decer[who][1] < 600)
                                    send("PRIVMSG %s :%s: Och nö, nicht schon wieder..." % [ @chan, src ])
                                else
                                    $karmas[who] -= 1
                                    $last_decer[who] = [ src.downcase, Time.new ]
                                end
                            end
                        end
                    end

                    def_match = /^\?!\s*([[:word:]♥+-]+)\s*=\s*(.*)$/.match(msg)
                    if def_match
                        ndesc = def_match[2]
                        dest = def_match[1].downcase

                        if /^\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])
                            ndesc = $watt[/^\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])[1].downcase]
                        elsif /^&\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])
                            reftarget = /^&\(\?\?\s*([[:word:]♥+-]+)\)$/.match(def_match[2])[1].downcase
                            if reftarget != dest
                                desc = $watt[reftarget]
                                while desc && (desc[0] == "ref") && (desc[1] != dest)
                                    desc = $watt[desc[1]]
                                end
                            end
                            if (reftarget == dest) || (desc && (desc[0] == "ref"))
                                send("PRIVMSG %s :%s: Du willst mich wohl verarschen; bastel dir doch aus zyklischen Graphen deinen Galgen, aber lass mich in Ruhe kthxbye -.-" % [ @chan, src ])
                                ndesc = nil
                            else
                                ndesc = [ "ref", reftarget ]
                            end
                        end
                        if ndesc
                            $watt[dest] = ndesc
                            $wfw[dest] = src
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

                    for url in $matches
                        um = url[0].match(msg)
                        if um
                            incoming = http_request((url[2] + (url[2].include?('<match>') ? '' : '<match>')).gsub('<match>', um[url[1]]))

                            if !incoming[0]
                                send("PRIVMSG #{@chan} :#{src} ist heute für einen #{incoming[1]} verantwortlich.")
                                break
                            end


                            title = nil


                            if url[3].kind_of?(Array)
                                matches = url[3].map { |m| m.match(incoming[1]) }
                                if !matches.include?(nil)
                                    title = eval(url[4])
                                end
                            else
                                title_match = url[3].match(incoming[1])
                                if title_match
                                    if url[4].kind_of?(Integer)
                                        title = title_match[url[4]]
                                    else
                                        title = eval(url[4])
                                    end
                                end
                            end

                            if title
                                title.gsub!(/<[^>]*>/, '')

                                title = CGI.unescapeHTML(title)

                                for char in $moarhtmlstuff
                                    title.gsub!(char[0], char[1])
                                end


                                title.strip!
                                title.gsub!(/\s+/, " ")

                                for appendix in url[5]
                                    title.gsub!(appendix, "")
                                end

                                break if title == ""

                                title = "Funny prank" if /\brickroll\b/i.match(title)

                                if (src == "alexander") || (src == "akluth") || (src == "DerHartmut")
                                    send("PRIVMSG %s :Der alte Lustmolch %s präsentiert Ihnen heute (Taschentücher bereithalten): „%s“" % [ @chan, src, title ])
                                else
                                    send("PRIVMSG %s :%s präsentiert Ihnen heute: „%s“" % [ @chan, src, title ])
                                end
                                send("PRIVMSG %s :nazi" % @chan) if /\b[Mm]ars?ch\b/.match(title)
                            end

                            break
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
            Thread.new do
            puts("\nShutting down, writing data to .rubybot...")
            File.open(".rubybot", "w") { |f|
                f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
            }
            puts("Done, exiting.")
            exit 0
            end
        end
    end
end

trap "HUP" do
    Thread.new do
        puts("\nShutting down, writing data to .rubybot...")
        File.open(".rubybot", "w") { |f|
            f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
        }
        puts("Done, exiting.")
        exit 0
    end
end

trap "TERM" do
    Thread.new do
        puts("\nShutting down, writing data to .rubybot...")
        File.open(".rubybot", "w") { |f|
            f.write({ "karmas" => $karmas, "watt" => $watt, "wfw" => $wfw, "urls" => $urls }.to_yaml)
        }
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
