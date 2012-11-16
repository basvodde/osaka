
module Osaka
  class Numbers < TypicalApplication
  
    def initialize
      super "Numbers"
    end
  
    def new_document
      super
      control.set_current_window(do_and_wait_for_new_window {
        control.keystroke(:return)
      })
    end
    
    def self.create_document(filename)
      numbers = Osaka::Numbers.new
      numbers.new_document
      yield numbers
      numbers.save_as(filename)
      numbers.close
    end
    
    def fill_cell(column, row, value)
      control.tell("tell document 1; tell sheet 1; tell table 1; set value of cell #{column} of row #{row} to \"#{value}\"; end tell; end tell; end tell")
    end
    
  end
end