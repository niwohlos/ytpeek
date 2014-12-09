[
    {
        resources:
        [
            {
                pattern: /twitter\.com\/(\w+\/status\/\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: [ /<p\s+class="[^"]*tweet-text[^"]*">(([^<]*|<[^\/]|<\/[^p])*)<\/p>/, /<span\s+class="[^"]*_timestamp[^"]*"\s+data-time="(\d+)"/, /<span>&rlm;<\/span><span\s+class="[^"]*username[^"]*"[^>]*><s>([^<]*)<\/s><b>([^<]*)</ ],
            group: '"[#{if Time.at(matches[1][1].to_i).strftime(\'%F\') == Time.new.strftime(\'%F\'); Time.at(matches[1][1].to_i).strftime(\'%T\'); else; Time.at(matches[1][1].to_i).strftime(\'%A, %-d. %B %Y] [%T\'); end}] &lt;#{matches[2][1]}#{matches[2][2]}&gt; #{matches[0][1]}"',
        },
        cleanurl: "https://twitter.com/",
        remove:
        [
        ]
    },
]