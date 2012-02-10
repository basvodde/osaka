
module Osaka
  
  class ApplicationWrapper
  
    def initialize(name)
      @name = name
    end
  
    def activate
      tell("activate")
    end
  
    def quit
      tell("quit")
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
    
    def wait_until_exists!(element_to_wait_for)
      system_event!("repeat until exists #{element_to_wait_for}; end repeat")
    end

    def wait_until_exists(element_to_wait_for)
      activate
      wait_until_exists!(element_to_wait_for)
    end
    
    def wait_until_not_exists!(element_to_wait_for)
      system_event!("repeat until not exists #{element_to_wait_for}; end repeat")
    end

    def wait_until_not_exists(element_to_wait_for)
      activate
      wait_until_not_exists!(element_to_wait_for)
    end
    
    def construct_modifier_statement(modifier_keys)
      modified_key_string = [ modifier_keys ].flatten.collect! { |mod_key| mod_key.to_s + " down"}.join(", ")
      modifier_command = " using {#{modified_key_string}}" unless modifier_keys.empty?
      modifier_command
    end
    
    def keystroke!(key, modifier_keys = [])
      system_event!("keystroke \"#{key}\"#{construct_modifier_statement(modifier_keys)}")
    end
    
    def keystroke(key, modifier_keys = [])
      activate
      keystroke!(key, modifier_keys)
    end
        
    def keystroke_and_wait_until_exists!(key, modifier_keys, element)
      keystroke!(key, modifier_keys)
      wait_until_exists!(element)
    end

    def keystroke_and_wait_until_exists(key, modifier_keys, element)
      activate
      keystroke_and_wait_until_exists!(key, modifier_keys, element)
    end
  
    def click!(element)
      system_event!("click #{element}")
    end

    def click(element)
      activate
      click!(element)
    end
  
    def click_and_wait_until_exists!(element, wait_condition)
      click!(element)
      wait_until_exists!(wait_condition)
    end

    def click_and_wait_until_exists(element, wait_condition)
      activate
      click_and_wait_until_exists!(element, wait_condition)
    end
  
    def click_and_wait_until_not_exists!(element, wait_condition)
      click!(element)
      wait_until_not_exists!(wait_condition)
    end

    def click_and_wait_until_not_exists(element, wait_condition)
      activate
      click_and_wait_until_not_exists!(element, wait_condition)
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