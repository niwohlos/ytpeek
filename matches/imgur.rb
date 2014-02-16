[
    {
        resources:
        [
            {
                pattern: /i\.imgur\.com\/(\w+)\./,
                group: 1,
            },
            {
                pattern: /imgur\.com\/(gallery\/)?(\w+)\b/,
                group: 2,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://imgur.com/",
        remove:
        [
            " - Imgur",
            "imgur: the simple image sharer",
            "imgur: the simple 404 page",
            "imgur: the simple overloaded page",
        ]
    },
]