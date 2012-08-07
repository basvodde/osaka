
module Osaka
  
  class KeynotePrintDialog < TypicalPrintDialog
  
  end

  class Keynote < TypicalApplication  
  
    def initialize
      super "Keynote"
    end

    def create_print_dialog(location)
      KeynotePrintDialog.new(location, @wrapper)
    end
    
    def select_all_slides
      if @wrapper.exists(at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1))
        @wrapper.click(at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1))
      else
        @wrapper.click(at.button("Slides").group(1).outline(1).scroll_area(1).splitter_group(1).splitter_group(1))
      end
      select_all
    end
  end
end