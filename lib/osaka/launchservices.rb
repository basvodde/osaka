
module Osaka
  module LaunchServices
    
    def self.dump
      Osaka::CommandRunner.run("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump")
    end
  end
end