
module Osaka

  class ConditionAndActionProxy
    
    def initialize(wrapper)
      @wrapper = wrapper
    end
    
    def create_condition_class_based_on_name(sym)
      classname = "#{sym.to_s[0].upcase}#{sym.to_s[1..-1]}Condition"
      eval(classname).new
    end

    def method_missing(sym, *args, &block)
      condition = create_condition_class_based_on_name(sym)
      @wrapper.enter_nested_action
      yield unless block.nil?
      @wrapper.exit_nested_action
      @wrapper.system_event!("repeat until #{condition.as_script(*args)}; #{@wrapper.nested_action} end repeat")
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
      @nested = false
    end
    
    def enter_nested_action
      @nested = true
      @nested_action = ""
    end
    
    def nested_action
      @nested_action
    end
    
    def exit_nested_action
      @nested = false
    end
    
    def execute_script(script)
      if @nested
        @nested_action += "#{script};"
      else 
        ScriptRunner::execute(script) unless @nested
      end
    end
    
    def activate
      tell("activate")
    end
  
    def quit
      tell("quit")
    end
  
    def tell(command)
      execute_script("tell application \"#{@name}\"; #{command}; end tell")
    end
  
    def system_event!(event)
      execute_script("tell application \"System Events\"; tell process \"#{@name}\"; #{event}; end tell; end tell")
    end

    def system_event(event)
      activate
      system_event!(event)
    end

    def wait_until
      activate
      wait_until!
    end
    
    def wait_until!
      ConditionAndActionProxy.new(self)
    end
    
    def until!
      ConditionAndActionProxy.new(self)
    end
        
    def construct_modifier_statement(modifier_keys)
      modified_key_string = [ modifier_keys ].flatten.collect! { |mod_key| mod_key.to_s + " down"}.join(", ")
      modifier_command = " using {#{modified_key_string}}" unless modifier_keys.empty?
      modifier_command
    end
    
    def keystroke!(key, modifier_keys = [])
      system_event!("keystroke \"#{key}\"#{construct_modifier_statement(modifier_keys)}")
      self
    end
    
    def keystroke(key, modifier_keys = [])
      activate
      keystroke!(key, modifier_keys)
    end
        
    def click!(element)
      system_event!("click #{element}")
      self
    end

    def click(element)
      activate
      click!(element)
    end
        
    def set!(element, value)
      system_event!("set #{element} to \"#{value}\"")
    end

    def set(element, value)
      activate
      set!(element, value)
    end
  end
end