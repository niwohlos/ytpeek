[
    {
        resources:
        [
            {
                pattern: /forum\.lowlevel\.eu\/index.php\?([^\s,]+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://forum.lowlevel.eu/index.php?",
        remove:
        [
        ]
    },
]