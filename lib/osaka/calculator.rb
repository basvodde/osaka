
module Osaka
  class Calculator < TypicalApplication
    attr_accessor :wrapper
    
    def initialize
      @name = "Calculator"
      @wrapper = ApplicationWrapper.new("Calculator")
    end
    
    def activate
      super
      if (@wrapper.window.nil?)
        wait_for_new_window([])
        @wrapper.window = @wrapper.window_list[0]
      end
    end
    
    def click(key)
      @wrapper.click!("button \"#{key}\" of group 2 of window \"#{@name}\"")
    end
    
    def key(k)
      @wrapper.keystroke(k)
    end
    
    def result
      @wrapper.get!('value', "static text 1 of group 1")
    end
    
  end
end