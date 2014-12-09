[
    {
        resources:
        [
            {
                pattern: /www\.youtube\.com\/watch\?((\w+=[\w-]+&)*)v=([\w-]+)/,
                group: 3,
            },
            {
                pattern: /youtu\.be\/([\w-]+)/,
                group: 1,
            },
            {
                pattern: /y2u\.be\/([\w-]+)/,
                group: 1,
            },
            {
                pattern: /www\.youtube\.com\/v\/([\w-]+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://www.youtube.com/watch?v=",
        remove:
        [
            " - YouTube",
        ]
    },
]