{
    name: "nsfb",
    enabled: true,
    help:
    [
    ],
    dependencies:
    [
    ],
    startup: Proc.new { |name, irc|
        FileUtils.mkdir_p "plugins/#{name}/data"

        $nsfb = load_data "plugins/#{name}/data"
        $nsfb.flatten!
    },
    shutdown: Proc.new { |name, irc|
    }
}