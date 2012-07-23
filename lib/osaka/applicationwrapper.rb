
module Osaka

  class InvalidLocation < RuntimeError
  end
  
  class ConditionProxy
    
    def initialize(wrapper, action)
      @wrapper = wrapper
      @action = action
    end
    
    def create_condition_class_based_on_name(sym)
      classname = "#{sym.to_s[0].upcase}#{sym.to_s[1..-1]}Condition"
      eval(classname).new
    end

    def method_missing(sym, *args, &block)
      condition = create_condition_class_based_on_name(sym)
      @action.execute(@wrapper, condition, *args, &block)      
    end
  end
  
  class RepeatAction
    def execute(wrapper, condition, *args, &block)
      while (!CheckAction.new.execute(wrapper, condition, *args, &block))
        yield unless block.nil?
      end
    end
  end
  
  class CheckAction
    def execute(wrapper, condition, *args, &block)
      wrapper.system_event!("#{condition.as_script(wrapper, *args)};").strip == "true"
    end
  end
  
  class ExistsCondition
    def as_script(wrapper, element_to_check)
      "exists #{wrapper.construct_location(element_to_check)}"
    end
  end
  
  class Not_existsCondition
    def as_script(wrapper, element_to_check)
      "not exists #{wrapper.construct_location(element_to_check)}"
    end
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

    def wait_until
      activate
      wait_until!
    end
    
    def check
      ConditionProxy.new(self, CheckAction.new)
    end
    
    alias check! check
    
    def until!
      ConditionProxy.new(self, RepeatAction.new)
    end
    
    alias wait_until! until!
        
    def construct_modifier_statement(modifier_keys)
      modified_key_string = [ modifier_keys ].flatten.collect! { |mod_key| mod_key.to_s + " down"}.join(", ")
      modifier_command = " using {#{modified_key_string}}" unless modifier_keys.empty?
      modifier_command
    end
    
    def keystroke!(key, modifier_keys = [])
      check_output( system_event!("keystroke \"#{key}\"#{construct_modifier_statement(modifier_keys)}"), "keystroke")
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