
# encoding: utf-8

module Osaka

  class SystemCommandFailed < RuntimeError
  end

  module CommandRunner
    def self.run(command, debug = false)
      puts "Execute: #{command} " if debug
      output = `#{command} 2>&1`
      raise Osaka::SystemCommandFailed, "message" + output unless $?.success?
      puts "Output was: #{output}" if debug
      output
    end
  end
end
    