[
    {
        resources:
        [
            {
                pattern: /boards\.4chan\.org\/((\w+)\/(res|thread)\/\d+)\S*#p(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: [ /.*/m ],
            group: 'post = JSON.parse(matches[0][0])["posts"].find { |p| p["no"].to_i == um[4].to_i }; if post; content = "[#{Time.at(post["time"].to_i).strftime("%T")}] #{unless post["com"].nil?; post["com"].gsub(/<\/?s>/, "\023"); else; ""; end}"; if post["tim"]; content + " (http://images.4chan.org/#{um[2]}/src/#{post["tim"]}#{post["ext"]})"; else; content; end; else "[Post im Thread nicht gefunden]"; end',
        },
        cleanurl: "http://a.4cdn.org/<match>.json",
        remove:
        [
        ]
    },
    {
        resources:
        [
            {
                pattern: /boards\.4chan\.org\/((\w+)\/(res|thread)\/\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: [ /.*/m ],
            group: 'op = JSON.parse(matches[0][0])["posts"][0]; "[#{Time.at(op["time"].to_i).strftime("%T")}] #{unless op["sub"].nil? || op["sub"].empty?; op["sub"]; else; unless op["com"].nil?; op["com"].gsub(/<\/?s>/, "\023"); else; ""; end; end} (http://images.4chan.org/#{um[2]}/src/#{op["tim"]}#{op["ext"]})"',
        },
        cleanurl: "http://a.4cdn.org/<match>.json",
        remove:
        [
        ]
    },
]
