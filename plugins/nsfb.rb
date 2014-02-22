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

        if File.exists? "plugins/#{name}/data/items.yaml"
            $nsfb = YAML.load_file "plugins/#{name}/data/items.yaml"
        end

    },
    shutdown: Proc.new { |name, irc|
    }
}