
module Osaka
  class TextEdit < TypicalApplication
    attr_accessor :wrapper
    
    def initialize
      @name = "TextEdit"
      @wrapper = ApplicationWrapper.new("TextEdit")
    end
    
    def type(text)
      @wrapper.keystroke(text)
    end
    
    def text
      @wrapper.get!("value", 'text area 1 of scroll area 1 of window "Untitled"')
    end
    
  end
end