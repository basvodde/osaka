
module Osaka
  class TextEdit < TypicalApplication
    attr_accessor :control
    
    def initialize
      @name = "TextEdit"
      @control = RemoteControl.new("TextEdit")
    end
    
    def type(text)
      control.keystroke(text)
    end
    
    def text
      control.get!("value", 'text area 1 of scroll area 1')
    end
    
  end
end
