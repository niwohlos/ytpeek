[
    {
        resources:
        [
            {
                pattern: /store\.steampowered\.com\/app\/(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://store.steampowered.com/app/<match>/?cc=us",
        remove:
        [
            " on Steam",
        ]
    },
]