require 'json'

class DefaultsSystem
  
  
  def initialize(domain)
    @domain = domain
    @settings = {}
    parse_settings_file(Osaka::CommandRunner.run("defaults read #{domain}"))
  end
  
  def parse_settings_file (settings_from_defaults)    
    scanner = StringScanner.new (settings_from_defaults)
    scanner.scan(/{\n/)
    while scanner.scan(/\s+(.*) = (.*);\n/) do
      @settings[scanner[1]] = scanner[2]
    end
  end
  
  def [](key)
    @settings[key]
  end
  
  def []=(key, value)
    Osaka::CommandRunner.run("defaults write #{@domain} #{key} #{value}")
  end
  
end
