[
    {
        resources:
        [
            {
                pattern: /boards\.4chan\.org\/((\w+)\/res\/\d+)#p(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: [ /.*/m ],
            group: 'post = JSON.parse(matches[0][0])["posts"].select { |p| p["no"].to_i == um[3].to_i }[0]; if post; content = "[#{Time.at(post["time"].to_i).strftime("%T")}] #{unless post["com"].nil?; post["com"].gsub(/<br.*$/, " […]"); else; ""; end}"; if post["tim"]; content + " (http://images.4chan.org/#{um[2]}/src/#{post["tim"]}#{post["ext"]})"; else; content; end; else "[Post im Thread nicht gefunden]"; end',
        },
        cleanurl: "http://boards.4chan.org/<match>.json",
        remove:
        [
        ]
    },
    {
        resources:
        [
            {
                pattern: /boards\.4chan\.org\/((\w+)\/res\/\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: [ /.*/m ],
            group: 'op = JSON.parse(matches[0][0])["posts"][0]; "[#{Time.at(op["time"].to_i).strftime("%T")}] #{unless op["sub"].nil? || op["sub"].empty?; op["sub"]; else; unless op["com"].nil?; op["com"].gsub(/<br.*$/, " […]"); else; ""; end; end} (http://images.4chan.org/#{um[2]}/src/#{op["tim"]}#{op["ext"]})"',
        },
        cleanurl: "http://boards.4chan.org/<match>.json",
        remove:
        [
        ]
    },
]