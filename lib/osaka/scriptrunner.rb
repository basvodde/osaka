# encoding: utf-8

module Osaka

  class ScriptRunnerError < RuntimeError
  end

  class TimeoutError < RuntimeError
  end

  class VersioningError < RuntimeError
  end

  module ScriptRunner

    @@debug_info_enabled = false

    def self.enable_debug_prints(debug_info_format = :plain_text, filename = "")
      @@debug_info_enabled = true
      @@debug_info_format = debug_info_format
      @@debug_info_script_filename = filename
    end

    def self.disable_debug_prints
      @@debug_info_enabled = false
    end

    def self.debug_prints?
      @@debug_info_enabled
    end

    def self.print_debug_info_for_escaped_commands(original_applescript_commands, escaped_commands)
      if (debug_prints?)
        if (@@debug_info_format == :plain_text)
          debug_output = "Executing: osascript#{escaped_commands}"
        elsif (@@debug_info_format == :short_html)
          debug_output = original_applescript_commands
          debug_output += "<br>"
        elsif (@@debug_info_format == :script)
          File.open(@@debug_info_script_filename, File::WRONLY|File::APPEND|File::CREAT, 0755) { |file|
            file.puts("osascript#{escaped_commands}")
          }
        end
        puts debug_output
      end
    end

    def self.print_debug_info_for_additional_output(output)
      if (!output.empty? && debug_prints?)
        if (@@debug_info_format == :plain_text)
          debug_output = "Output was: #{output}"
        elsif (@@debug_info_format == :short_html)
          debug_output = "Output: <b>#{output}</b><br>"
        end
        puts debug_output
      end
    end

    def self.execute(applescript)
      script_commands = applescript.gsub("\"", "\\\"").split(';')
      escaped_commands = ""
      script_commands.each { |l|
        escaped_commands += " -e \"#{l.strip}\""
      }

      print_debug_info_for_escaped_commands(applescript, escaped_commands)

      output = ""
      begin
        output = CommandRunner::run("osascript#{escaped_commands}")
      rescue Osaka::SystemCommandFailed => ex
        if ex.message =~ /assistive devices/
          puts <<-eom
            Osaka execution failed with the error: #{ex.message}
            The reason for this is probably that you didn't enable the acess for assistive devices.
            Without this enabled, Osaka won't be able to execute applescript and thus won't work.
            You can turn this on (in mountain lion) under:
               system preferences -> Accessibility -> Enable access for assistive devices
            If you are under snow leopard, it is under:
               system preferences -> Universal Access -> Enable access for assistive devices

            Osaka will not continue as it won't work without this enabled. Please enable it and re-run.
          eom
          exit
          return
        end
        raise(Osaka::ScriptRunnerError, "Error received while executing: \"#{applescript}\" with message \"#{ex.message}\"")
      end
      print_debug_info_for_additional_output(output)
      output
    end

    def self.execute_file(scriptName, parameters = "")
      CommandRunner::run("osascript #{scriptName} #{parameters}".strip)
    end

  end
end
