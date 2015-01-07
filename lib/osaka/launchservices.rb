
module Osaka
  module LaunchServices

    def self.dump
      Osaka::CommandRunner.run("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump")
    end

    def self.retrieve(bundle_name)
      launch_services_dump = Osaka::CommandRunner.run("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump")
      current_hash = {}
      launch_services_hash = {}

      launch_services_dump.each_line do |line|
        if line =~ /^(\w.*):\s+(\w.*)$/
          launch_services_hash[current_hash[:name]] = current_hash
          current_hash = {:id => $2}
        end
        if line =~ /^\t(\w.*):\s+(\w.*)$/
          current_hash[$1.to_sym] = $2
          #puts current_hash
        end
      end
      launch_services_hash[current_hash[:name]] = current_hash
      launch_services_hash[bundle_name]
    end

  end
end
