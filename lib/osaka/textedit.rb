
module Osaka
  class TextEdit < TypicalApplication
    attr_accessor :wrapper
    
    def initialize
      @name = "TextEdit"
      @wrapper = ApplicationWrapper.new("TextEdit")
    end
    
    def activate
      super
      if (@wrapper.window.nil?)
        wait_for_new_window([])
        @wrapper.window = @wrapper.window_list[0]
      end
    end
    
    def type(text)
      @wrapper.keystroke(text)
    end
    
    def text
      @wrapper.get!("value", 'text area 1 of scroll area 1')
    end
    
  end
end