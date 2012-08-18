
module Osaka
  
  class ScriptRunnerError < RuntimeError
  end
  
  class SystemCommandFailed < RuntimeError
  end

  class TimeoutError < RuntimeError
  end

  class VersioningError < RuntimeError
  end
  
  module ScriptRunner

    @@debug_info_enabled = false

    def self.enable_debug_prints(debug_info_format = :plain_text)
      @@debug_info_enabled = true
      @@debug_info_format = debug_info_format
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
      if (debug_prints?)
        if (@@debug_info_format == :plain_text)
          debug_output = "Executing: osascript#{escaped_commands}"
        elsif (@@debug_info_format == :short_html)
          debug_output = applescript
          debug_output += "<br>"
        end        
        puts debug_output
      end
      

      output = ""
      begin
        output = do_system("osascript#{escaped_commands}")
      rescue Osaka:: SystemCommandFailed
        raise(Osaka::ScriptRunnerError, "Error received while executing: #{applescript}")
      end
      if (!output.empty? && debug_prints?)
        if (@@debug_info_format == :plain_text)
          debug_output = "Output was: #{output}"
        elsif (@@debug_info_format == :short_html)
          debug_output = "Output: <b>#{output}</b><br>"
        end        
        puts debug_output
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
