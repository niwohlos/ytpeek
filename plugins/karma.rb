{
    name: "karma",
    enabled: true,
    help:
    [
        "!karma [x] – Wie ist [x]?",
        "[x]++, [x]-- – So ist [x]!",
    ],
    dependencies:
    [
    ],
    startup: Proc.new { |name|
        FileUtils.mkdir_p "plugins/#{name}/data"

        if File.exists? "plugins/#{name}/data/#{name}.yaml"
            settings = YAML.load_file "plugins/#{name}/data/#{name}.yaml"

            if settings
                $karmas = settings["karmas"]
            end

            $karmas = Hash.new if !$karmas
        end
    },
    shutdown: Proc.new { |name|
        FileUtils.mkdir_p "plugins/#{name}/data"

        File.open("plugins/#{name}/data/#{name}.yaml", "w") { |f|
            f.write({ "karmas" => $karmas }.to_yaml)
        }
    }
}