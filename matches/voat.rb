[
    {
        resources:
        [
            {
                pattern: /voat\.co\/(v\/.*)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "https://voat.co/",
        remove:
        [
            -> (title, url) { title.gsub(" | " + url.match(/voat\.co\/v\/([^\/]+)/)[1], '') rescue NoMethodError }
        ]
    },
]