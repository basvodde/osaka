
require 'timeout'

module Osaka

  class InvalidLocation < RuntimeError
  end

  class RemoteControl

    attr_reader :name
    attr_accessor :base_location

    @@debug_info_enabled = false

    def self.enable_debug_prints
      @@debug_info_enabled = true
    end

    def debug_print(message)
      puts message if @@debug_info_enabled
    end

    def initialize(name, base_location = Location.new(""))
      @name = name
      @base_location = base_location
    end

    def ==(obj)
      @name == obj.name && base_location == obj.base_location
    end

    def tell(command)
      ScriptRunner::execute("tell application \"#{@name}\"; #{command}; end tell")
    end

    def system_event!(event)
      ScriptRunner::execute("tell application \"System Events\"; tell process \"#{@name}\"; #{event}; end tell; end tell")
    end

    def running?
      ScriptRunner::execute("tell application \"System Events\"; (name of processes) contains \"#{@name}\"; end tell").strip == "true"
    end

    def print_warning(action, message)
      puts "Osaka WARNING while doing #{action}: #{message}"
    end

    def check_output(output, action)
      print_warning(action, output) unless output.empty?
      output
    end

    def activate
      check_output( tell("activate"), "activate" )
    end

    def launch
      check_output( tell("launch"), "launch" )
    end

    def quit
      keystroke("q", :command)
    end

    def system_event(event)
      activate
      system_event!(event)
    end

    def exists?(location)
      system_event!("exists #{construct_location(location)}").strip == "true"
    end

    def not_exists?(location)
      system_event!("not exists #{construct_location(location)}").strip == "true"
    end

    def wait_until(locations, action)

      begin
        Timeout::timeout(10) {
          while(true)
              locations.flatten.each { |location|
                return location if yield location
            }
            action.() unless action.nil?
          end
        }
      rescue Exception
        raise Osaka::TimeoutError, "Timed out while waiting for: #{locations.join(", ")}"
      end
    end

    def wait_until_exists(*locations, &action)
      activate
      wait_until_exists!(*locations, &action)
    end

    def wait_until_exists!(*locations, &action)
      wait_until(locations, action) { |location|
        debug_print "Waiting until exists: #{location.to_s} on remote #{current_window_name.to_s}"
        exists?(location)
      }
    end

    alias until_exists wait_until_exists
    alias until_exists! wait_until_exists!

    def wait_until_not_exists(*locations, &action)
      activate
      wait_until_not_exists!(*locations, &action)
    end

    def wait_until_not_exists!(*locations, &action)
      wait_until(locations, action) { |location|
        not_exists?(location)
      }
    end

    alias until_not_exists wait_until_not_exists
    alias until_not_exists! wait_until_not_exists!


    def construct_modifier_statement(modifier_keys)
      modified_key_string = [ modifier_keys ].flatten.collect! { |mod_key| mod_key.to_s + " down"}.join(", ")
      modifier_command = " using {#{modified_key_string}}" unless modifier_keys.empty?
      modifier_command
    end

    def construct_key_statement(key_keys)
      return "return" if key_keys == :return
      "\"#{key_keys}\""
    end

    def keystroke!(key, modifier_keys = [])
      check_output( system_event!("keystroke #{construct_key_statement(key)}#{construct_modifier_statement(modifier_keys)}"), "keystroke")
      self
    end

    def keystroke(key, modifier_keys = [])
      activate
      focus
      (modifier_keys == []) ? keystroke!(key) : keystroke!(key, modifier_keys)
    end

    def click!(element)
      # Click seems to often output stuff, but it doesn't have much meaning so we ignore it.
      system_event!("click #{construct_location(element)}")
      self
    end

    def click(element)
      activate
      click!(element)
    end

    def click_menu_bar(menu_item, menu_name)
      activate
      menu_bar_location = at.menu_bar_item(menu_name).menu_bar(1)
      click!(menu_item + at.menu(1) + menu_bar_location)
    end

    def set!(element, location, value)
      encoded_value = (value.class == String) ? "\"#{value}\"" : value.to_s
      check_output( system_event!("set #{element}#{construct_prefixed_location(location)} to #{encoded_value}"), "set")
    end

    def focus
      if (base_location.to_s.empty? || not_exists?(base_location))
        currently_active_window = window_list[0]
        currently_active_window ||= ""
        @base_location = (currently_active_window.to_s.empty?) ? Location.new("") : at.window(currently_active_window)
      end

      focus!
    end

    def focus!
      system_event!("set value of attribute \"AXMain\" of #{base_location.top_level_element} to true") unless base_location.top_level_element.to_s.empty?
    end

    def form_location_with_window(location)
      new_location = Location.new(location)
      new_location += @base_location unless new_location.has_top_level_element?
      new_location
    end

    def construct_location(location)
      form_location_with_window(location).to_s
    end

    def construct_prefixed_location(location)
      form_location_with_window(location).as_prefixed_location
    end

    def get!(element, location = "")
      debug_print "Getting attribute '#{element}' of: #{construct_prefixed_location(location)}"
      system_event!("get #{element}#{construct_prefixed_location(location)}").strip
    end

    def get_app!(element)
      system_event!("get #{element}").strip
    end

    def attributes(location = "")
      attributelist = get!("attributes", location)
      attributelist.split("of application process #{name}").collect { |attribute|
        attribute.match("attribute (.+?) .*")[1]
      }
    end

    def set(element, location, value)
      activate
      set!(element, location, value)
    end

    def window_list
      windows = get_app!("windows").strip.split(',')
      windows.collect { |window|
        window[7...window =~ / of application process/].strip
      }
    end

    def standard_window_list
      window_list.collect { |window|
        if exists?(at.window(window)) && get!("subrole", at.window(window)) == "AXStandardWindow"
          window
        end
      }.compact
    end

    def set_current_window(window_name)
      debug_print "Changing remote base location to: #{window_name}"
      @base_location = at.window(window_name)
    end

    def current_window_name
      matchdata = @base_location.to_s.match(/window "(.*)"/)
      return "" if matchdata.nil? || matchdata[1].nil?
      matchdata[1]
    end

    def current_window_invalid?(window_list)
      @base_location.to_s.empty? || window_list.index(current_window_name).nil?
    end

    def mac_version_string_to_name(mac_version_string)
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
        else
          :other
      end
    end

    def mac_version_name_to_number(mac_version_name)
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
        else
          :other
      end
    end

    def mac_version
      mac_version_string_to_name(mac_version_string)
    end

    def mac_version_before(mac_version_name)
      current_mac_version_string = Osaka::ScriptRunner.execute("system version of (system info)").strip
      current_mac_version_number = mac_version_name_to_number(mac_version_string_to_name(current_mac_version_string))
      before_mac_version_number = mac_version_name_to_number(mac_version_name)
      current_mac_version_number < before_mac_version_number
    end

    def mac_version_string
      Osaka::ScriptRunner.execute("system version of (system info)").strip
    end


    def convert_mac_version_string_to_symbol(version_string)

    end

  end
end
