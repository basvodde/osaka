
module Osaka
  
  class KeynotePrintDialog < TypicalPrintDialog
  
  end

  class Keynote < TypicalApplication  
  
    def initialize
      super "Keynote"
    end

    def create_print_dialog(location)
      KeynotePrintDialog.new(location, app)
    end
  end
end