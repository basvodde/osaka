
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
      light_table_view
      select_all
    end

    def light_table_view
      if control.exists?(at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1))
        control.click(at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1))
      end
    end
  end
end
