[
    {
        resources:
        [
            {
                pattern: /www\.hlportal\.de\/\?site=news&do=shownews&news_id=(\d+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<h1\ class="news_headline">(.*)<\/h1>/im,
            group: 1,
        },
        cleanurl: "http://www.hlportal.de/?site=news&do=shownews&news_id=",
        remove:
        [
        ]
    },
]
