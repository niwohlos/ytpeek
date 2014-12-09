$match_rules = []

(Dir.entries("matches") - [ ".", ".." ]).each do |match_rule_file|
    match_rule_source = File.read "matches/#{match_rule_file}"
    match_rule = eval match_rule_source

    $match_rules << match_rule
end

class Hash
    alias old_method_missing method_missing

    def method_missing *args
        if args.size.eql?(1) && args.first.is_a?(Symbol) && self.has_key?(args.first)
            self[args.first]
        else
            old_method_missing *args
        end
    end
end

$match_rules.each do |rules|
    rules.each do |rule|
        puts "rule:"
        puts "\tcleanurl: #{rule.cleanurl}"
        puts "\tresources:"

        rule.resources.each do |resource|
            puts "\t\t#{resource.group} :: #{resource.pattern.inspect}"
        end

        puts "\ttitle: #{rule.title.group} :: #{rule.title.pattern}"
        puts "\tremove:"

        rule.remove.each do |remove|
            puts "\t\t#{remove}"
        end
    end
end