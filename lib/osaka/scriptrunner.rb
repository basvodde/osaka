
module Osaka
  
  class ScriptRunnerError < RuntimeError
  end
  
  class SystemCommandFailed < RuntimeError
  end

  module ScriptRunner

    @@debug_info_enabled = false

    def self.enable_debug_prints
      @@debug_info_enabled = true
    end

    def self.disable_debug_prints
      @@debug_info_enabled = false
    end

    def self.debug_prints?
      @@debug_info_enabled
    end
  
    def self.execute(applescript)
      script_commands = applescript.gsub("\"", "\\\"").split(';')
      escaped_commands = "" 
      script_commands.each { |l| 
        escaped_commands += " -e \"#{l.strip}\""
      }
      puts "Executing: osascript#{escaped_commands}" if debug_prints?

      output = ""
      begin
        output = do_system("osascript#{escaped_commands}")
      rescue Osaka:: SystemCommandFailed
        raise(Osaka::ScriptRunnerError, "Error received while executing: #{applescript}")
      end
      if (!output.empty? && debug_prints?)
        puts "Output was: #{output}"
      end
      output
    end  
  
    def self.execute_file(scriptName, parameters = "")
      do_system("osascript #{scriptName} #{parameters}".strip)
    end

  private
    def self.do_system(command)
      output = `#{command}`
      raise Osaka::SystemCommandFailed unless $?.success?
      output
    end
  end
end
