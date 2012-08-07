
module Osaka

  class InvalidLocation < RuntimeError
  end
  
  class ApplicationWrapper
  
    attr_reader :name
    
    def initialize(name)
      @name = name
      @window = Location.new("")
    end
    
    def ==(obj)
      @name == obj.name && current_window_name == obj.current_window_name
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
  
    def quit
      keystroke("q", :command)
    end  

    def system_event(event)
      activate
      system_event!(event)
    end

    def exists(location)
      system_event!("exists #{construct_location(location)}").strip == "true"
    end

    def not_exists(location)
      system_event!("not exists #{construct_location(location)}").strip == "true"
    end
        
    def wait_until(locations, action)
      while(true)
          locations.flatten.each { |location| 
            return location if yield location
        }
        action.() unless action.nil?
      end
    end
    
    def wait_until_exists(*locations)
      activate
      wait_until_exists!(locations)
    end
    
    def wait_until_exists!(*locations, &action)
      wait_until(locations, action) { |location|
        exists(location)
      }
    end
    
    alias until_exists wait_until_exists
    alias until_exists! wait_until_exists!

    def wait_until_not_exists(*locations, &action)
      activate
      wait_until_not_exists!(*locations, action)
    end

    def wait_until_not_exists!(*locations, &action)
      wait_until(locations, action) { |location|
        not_exists(location)
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
      keystroke!(key, modifier_keys)
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
      current_windows = window_list
      currently_active_window = current_windows[0]
      currently_active_window ||= ""
      
      if current_window_invalid?(current_windows)
        @window = at.window(currently_active_window) unless currently_active_window.nil?
      end

      set!("value", "attribute \"AXMain\"", true) unless currently_active_window == current_window_name
    end
    
    def form_location_with_window(location)
      new_location = Location.new(location)
      new_location += @window unless new_location.has_top_level_element?
      new_location
    end
    
    def construct_location(location)
      form_location_with_window(location).to_s
    end

    def construct_prefixed_location(location)
      form_location_with_window(location).as_prefixed_location
    end
    
    def get!(element, location = "")
      system_event!("get #{element}#{construct_prefixed_location(location)}").strip
    end

    def get_app!(element)
      system_event!("get #{element}").strip
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
    
    def set_current_window(window_name)
      @window = at.window(window_name)
    end
    
    def current_window_name
      matchdata = @window.to_s.match(/^window "(.*)"/)
      return "" if matchdata.nil? || matchdata[1].nil?
      matchdata[1]
    end
    
    def current_window_location
      @window
    end
    
    def current_window_invalid?(window_list)
      @window.to_s.empty? || window_list.index(current_window_name).nil?
    end
    
  end
end