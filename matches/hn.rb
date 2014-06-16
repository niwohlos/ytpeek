[
    {
        resources:
        [
            {
                pattern: /news\.ycombinator\.com\/item\?id(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://news.ycombinator.com/item?id=",
        remove:
        [
            " | Hacker News"
        ]
    },
]
