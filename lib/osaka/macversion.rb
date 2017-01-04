# encoding: utf-8

class MacVersion

  attr_reader :version

  def self.get
    @simulated_version || MacVersion.new
  end

  def self.simulate(version)
    @simulated_version = MacVersion.new(version)
    yield
    @simulated_version = nil
  end

  def initialize(version = nil)
    @version = version || version_string_to_name(system_version)
  end

  def system_version
    Osaka::ScriptRunner.execute("system version of (system info)").strip
  end

  def version_before(mac_version_name)
    current_mac_version_number = version_name_to_number(@version)
    before_mac_version_number = version_name_to_number(mac_version_name)
    current_mac_version_number < before_mac_version_number
  end

  def version_string_to_name(mac_version_string)
    case mac_version_string
    when /^10.6.*/
      :snow_leopard
    when /^10.7.*/
      :lion
    when /^10.8.*/
      :mountain_lion
    when /^10.10.*/
      :yosemite
    when /^10.11.*/
      :el_capitain
    when /^10.12.*/
      :sierra
    else
      :other
    end
  end

  def version_name_to_number(mac_version_name)
    case mac_version_name
    when :snow_leopard
      10.6
    when :lion
      10.7
    when :mountain_lion
      10.8
    when :yosemite
      10.10
    when :el_capitain
      10.11
    when :sierra
      10.12
    else
      :other
    end
  end
end

