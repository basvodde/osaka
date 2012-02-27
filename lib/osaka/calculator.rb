
module Osaka
  class Calculator
    attr_accessor :wrapper
    
    def initialize
      @name = "Calculator"
      @wrapper = ApplicationWrapper.new("Calculator")
    end
    
    def click(key)
      @wrapper.click!("button \"#{key}\" of group 2 of window \"#{@name}\"")
    end
    
    def key(k)
      @wrapper.keystroke!(k)
    end
    
    def result
      @wrapper.get!('value', "static text 1 of group 1 of window \"#{@name}\"")
    end
    
    def activate
      @wrapper.activate
    end
    
    def quit
      @wrapper.quit
    end
        
  end
end