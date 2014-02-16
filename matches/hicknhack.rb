[
    {
        resources:
        [
            {
                pattern: /tud\.hicknhack\.org\/forum\/messages\/(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<div class="head">([^<]*)/i,
            group: 1,
        },
        cleanurl: "http://tud.hicknhack.org/forum/messages/",
        remove:
        [
        ]
    },
]