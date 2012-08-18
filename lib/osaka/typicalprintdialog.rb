# encoding: utf-8
module Osaka
  
  class TypicalPrintDialog
    attr_accessor :control

    def initialize(parent, control)
      @parent = parent
      @control = control
    end
  
    def create_save_dialog(location, app)
      TypicalSaveDialog.new(location, app)
    end

    def save_as_pdf(filename)
      control.click!(at.menu_button("PDF") + @parent).wait_until_exists!(at.menu(1).menu_button("PDF") + @parent)
      control.click!(at.menu_item(2).menu(1).menu_button("PDF") + @parent)
      
      save_location = control.wait_until_exists!(at.window("Save"), at.sheet(1).window("Print"))      
      save_dialog = create_save_dialog(save_location, control)
      save_dialog.save(filename)
      
      control.until_not_exists!(@parent) {
        # Weird, but sometimes the dialog "hangs around" and clicking this checkbox will make it go away.
        # Anyone who knows a better solution, please let me know!
        # This is for snow leopard
        control.click!(at.checkbox(1) + @parent) if control.exists(at.checkbox(1) + @parent)
      }
    end
  end
  
end