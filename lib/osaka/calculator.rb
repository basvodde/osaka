
module Osaka
  class Calculator < TypicalApplication
    attr_accessor :wrapper
    
    def initialize
      @name = "Calculator"
      @wrapper = ApplicationWrapper.new("Calculator")
      @wrapper.set_current_window(@name)
    end
    
    def activate
      super
      if (@wrapper.current_window_name.empty?)
        wait_for_new_window([])
        @wrapper.set_current_window(@wrapper.window_list[0])
      end
    end
    
    def click(key)
      @wrapper.click!(at.button(key).group(2))
    end
    
    def key(k)
      @wrapper.keystroke(k)
    end
    
    def result
      @wrapper.get!('value', at.static_text(1).group(1))
    end
  end
end