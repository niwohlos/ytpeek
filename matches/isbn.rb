[
    {
        resources:
        [
            {
                pattern: /(?=\d{3}-\d{1,5}-\d{1,7}-\d{1,7}-\d)(\A[0-9-]{17}\z)/,
                group: 2,
            },
        ],
        title:
        {
            pattern: /<h2>([^<]*)<\/h2>/,
            group: 1,
        },
        cleanurl: "http://www.isbnsearch.org/isbn/",
        remove:
        [
        ]
    },
]