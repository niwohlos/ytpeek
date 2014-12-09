{
    name: "watt",
    enabled: true,
    help:
    [
        "?? [x] – Was ist [x]?",
        "?! [x] – Das ist [x]!",
    ],
    dependencies:
    [
    ],
    startup: Proc.new { |name|
        FileUtils.mkdir_p "plugins/#{name}/data"

        if File.exists? "plugins/#{name}/data/#{name}.yaml"
            settings = YAML.load_file "plugins/#{name}/data/#{name}.yaml"

            if settings
                $watt = settings["watt"]
                $wfw  = settings["wfw" ]
            end

            $watt = Hash.new if !$watt
            $wfw  = Hash.new if !$wfw
        end
    },
    shutdown: Proc.new { |name|
        FileUtils.mkdir_p "plugins/#{name}/data"

        File.open("plugins/#{name}/data/#{name}.yaml", "w") { |f|
            f.write({ "watt" => $watt, "wfw" => $wfw }.to_yaml)
        }
    }
}