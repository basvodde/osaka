
module Osaka
  
  class KeynotePrintDialog < TypicalPrintDialog
  
  end

  class Keynote < TypicalApplication  
  
    def initialize
      super "Keynote"
    end

    def create_print_dialog(location)
      KeynotePrintDialog.new(control.name, at.window("Print"))
    end
    
    def select_all_slides
      if control.exists?(at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1))
        control.click(at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1))
      else
        control.click(at.button("Slides").group(1).outline(1).scroll_area(1).splitter_group(1).splitter_group(1))
      end
      select_all
    end
  end
end