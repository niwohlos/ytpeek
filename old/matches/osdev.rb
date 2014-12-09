[
    {
        resources:
        [
            {
                pattern: /forum\.osdev\.org\/viewtopic.php\?([^\s,]+)/,
                group: 1,
            },
        ],
        title:
        {
            pattern: /<title>(.*)<\/title>/im,
            group: 1,
        },
        cleanurl: "http://forum.osdev.org/viewtopic.php?",
        remove:
        [
            "OSDev.org • View topic - ",
        ]
    },
]