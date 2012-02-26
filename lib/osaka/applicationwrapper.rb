
module Osaka

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
    def as_script(element_to_wait_for)
      "exists #{element_to_wait_for}"
    end
  end
  
  class Not_existsCondition
    def as_script(element_to_wait_for)
      "not exists #{element_to_wait_for}"
    end
  end
    
  class ApplicationWrapper
  
    def initialize(name)
      @name = name
    end
    
    def print_warning(action, message)
      puts "Osaka WARNING while doing #{action}: #{message}"
    end
    
    def check_output(output, action)
      if (!output.empty?)
        print_warning(action, output)
      end
      output
    end
    
    def activate
      check_output( tell("activate"), "activate" )
    end
  
    def quit
      check_output( tell("quit"), "quit" )
    end
  
    def tell(command)
      ScriptRunner::execute("tell application \"#{@name}\"; #{command}; end tell")
    end
  
    def system_event!(event)
      ScriptRunner::execute("tell application \"System Events\"; tell process \"#{@name}\"; #{event}; end tell; end tell")
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
    
    def wait_until!
      ConditionProxy.new(self, RepeatAction.new)
    end
    
    def until!
      ConditionProxy.new(self, RepeatAction.new)
    end
        
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
      check_output( system_event!("set #{element} of #{location} to \"#{value}\""), "set")
    end
    
    def get!(element, location)
      system_event!("get #{element} of #{location}")
    end

    def set(element, location, value)
      activate
      set!(element, location, value)
    end
  end
end