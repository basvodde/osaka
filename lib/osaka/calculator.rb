
module Osaka
  class Calculator < TypicalApplication

    attr_accessor :control
    
    def initialize
      @name = "Calculator"
      @control = RemoteControl.new("Calculator")
      control.set_current_window(@name)
    end
    
    def activate
      super
      if (control.current_window_name.empty?)
        wait_for_new_window([])
        control.set_current_window(control.window_list[0])
      end
    end
    
    def click(key)
      control.click!(at.button(key).group(2))
    end
    
    def key(k)
      control.keystroke(k)
    end
    
    def result
      control.wait_until_exists!(at.static_text(1).group(1))
      control.get!('value', at.static_text(1).group(1))
    end
  end
end
