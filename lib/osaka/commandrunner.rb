
# encoding: utf-8

module Osaka

  class SystemCommandFailed < RuntimeError
  end

  module CommandRunner
    def self.run(command)
      output = `#{command} 2>&1`
      raise Osaka::SystemCommandFailed, "message" + output unless $?.success?
      output
    end
  end
end
    
