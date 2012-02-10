
module Osaka
  class Numbers < TypicalApplication
  
    def initialize
      super "Numbers"
    end
  
    def fill_cell(column, row, value)
      @wrapper.tell("tell document 1; tell sheet 1; tell table 1; set value of cell #{column} of row #{row} to \"#{value}\"; end tell; end tell; end tell")
    end
  end
end