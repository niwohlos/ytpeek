[
    {
        resources:
        [
            {
                pattern: /sukebei\.nyaa\.eu\/\?page=torrentinfo&tid=(\d+)/,
                group: 1,
            },
            {
                pattern: /sukebei\.nyaa\.eu\/\?page=download&tid=(\d+)/,
                group: 1,
            }
        ],
        title:
        {
            pattern: /<td\ class="tinfotorrentname">([^<]*)<\/td>/,
            group: 1,
        },
        cleanurl: "http://sukebei.nyaa.eu/?page=torrentinfo&tid=",
        remove:
        [
        ]
    },
    {
        resources:
        [
            {
                pattern: /nyaa\.eu\/\?page=torrentinfo&tid=(\d+)/,
                group: 1,
            },
            {
                pattern: /nyaa\.eu\/\?page=download&tid=(\d+)/,
                group: 1,
            }
        ],
        title:
        {
            pattern: /<td\ class="tinfotorrentname">([^<]*)<\/td>/,
            group: 1,
        },
        cleanurl: "http://www.nyaa.eu/?page=torrentinfo&tid=",
        remove:
        [
        ]
    },
]