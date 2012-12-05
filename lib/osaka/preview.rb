
module Osaka
  
  class Preview < TypicalApplication
    
    attr_accessor :control
    
    def initialize
      super "Preview"
    end
    
    def pdf_content
      control.get!("value", at.static_text(1).scroll_area(1).splitter_group(1))
    end
  end
end