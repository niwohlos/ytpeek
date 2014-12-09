{
    name: "wtf",
    enabled: true,
    help:
    [
        "!wtfids [x] – Wie und was ist das",
        "!pdp – Wie und was ist irgendwas",
    ],
    dependencies:
    [
        "watt",
        "karma"
    ],
    startup: Proc.new { |name|
    },
    shutdown: Proc.new { |name|
    }
}