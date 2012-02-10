
module Osaka
  
  class ScriptRunnerError < RuntimeError
  end

  module ScriptRunner

    @@debug_info_enabled = false

    def self.enabled_debug_prints
      @@debug_info_enabled = true
    end

    def self.disable_debug_prints
      @@debug_info_enabled = false
    end

    def self.debug_prints?
      @@debug_info_enabled
    end
  
    def self.execute(applescript)
      script_commands = applescript.gsub('"', '\\"').split(';')
      escaped_commands = "" 
      script_commands.each { |l| 
        escaped_commands += " -e \"#{l.strip}\""
      }
      puts "Executing: osascript#{escaped_commands}" if debug_prints?
      
      raise(Osaka::ScriptRunnerError, "Error received while executing: #{applescript}") unless system("osascript#{escaped_commands}")
    end  
  
    def self.execute_file(scriptName, parameters = "")
      system("osascript #{scriptName} #{parameters}".strip)
    end
  end
end
