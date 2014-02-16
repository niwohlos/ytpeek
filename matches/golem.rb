[
    {
        resources:
        [
            {
                pattern: /golem\.de\/(\d+\/[\d-]+\.html)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://www.golem.de/",
        remove:
        [
            " - Golem.de",
        ]
    },
]