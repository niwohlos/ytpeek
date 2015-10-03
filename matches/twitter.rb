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
            pattern: [ /<meta\s+property="og:description"\s+content="“?([^”"]*)/, /<strong\s+class="[^"]*fullname[^"]*"[^>]*>([^<]*)/ ],
            group: '"&lt;#{matches[1][1]}&gt; #{matches[0][1]}"'
        },
        cleanurl: "https://twitter.com/",
        remove:
        [
        ]
    },
]
