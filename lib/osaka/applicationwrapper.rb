
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
      wrapper.system_event!("#{condition.as_script(*args)};").strip == "true"
    end
  end
  
  class ExistsCondition
    def as_script(element_to_check)
      "exists #{element_to_check}"
    end
  end
  
  class Not_existsCondition
    def as_script(element_to_check)
      "not exists #{element_to_check}"
    end
  end
    
  class ApplicationWrapper
  
    attr_accessor :window
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
    
    def ==(obj)
      @name == obj.name && window == obj.window
    end
    
    def tell(command)
      ScriptRunner::execute("tell application \"#{@name}\"; #{command}; end tell")
    end
  
    def system_event!(event)
      ScriptRunner::execute("tell application \"System Events\"; tell process \"#{@name}\"; #{event}; end tell; end tell")
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
      system_event!("click #{element}")
      self
    end

    def click(element)
      activate
      click!(element)
    end
        
    def set!(element, location, value)
      encoded_value = (value.class == String) ? "\"#{value}\"" : value.to_s
      check_output( system_event!("set #{element} of #{location} to #{encoded_value}"), "set")
    end
    
    def focus
      current_windows = window_list
      @window = current_windows[0] if @window.nil? || current_windows.index(@window).nil?
      set!("value", "attribute \"AXMain\" of window \"#{window}\"", true) if current_windows[0] != @window
    end
    
    def construct_window_info(location)
      location_string = ""
      location_string += " of #{location}" unless location.empty?
      location_string += " of window \"#{window}\"" unless window.nil?
      
      raise(Osaka::InvalidLocation, "Invalid location for command:#{location_string}") if location_string.scan("of window").length > 1
      
      location_string
    end
    
    def get!(element, location = "")
      system_event!("get #{element}#{construct_window_info(location)}").strip
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
  end
end