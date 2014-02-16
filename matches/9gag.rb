[
    {
        resources:
        [
            {
                pattern: /9gag\.com\/gag\/(\d+)/,
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