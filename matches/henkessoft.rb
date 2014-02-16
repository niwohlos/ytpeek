[
    {
        resources:
        [
            {
                pattern: /www\.henkessoft300\.de/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://www.henkessoft3000.de",
        remove:
        [
            " lol henkes content is best content!",
        ]
    },
]