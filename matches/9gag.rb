[
    {
        resources:
        [
            {
                pattern: /9gag\.com\/gag\/([a-zA-Z0-9]+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://9gag.com/gag/",
        remove:
        [
            "9GAG - ",
        ]
    },
]