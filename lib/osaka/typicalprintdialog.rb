# encoding: utf-8
module Osaka
  
  class TypicalPrintDialog
    attr_accessor :control

    def initialize(application_name, own_location)
      @control = Osaka::RemoteControl.new(application_name, own_location)
    end
  
    def create_save_dialog(application_name, own_location)
      TypicalSaveDialog.new(application_name, own_location)
    end

    def save_as_pdf(filename)
      control.click!(at.menu_button("PDF")).wait_until_exists!(at.menu(1).menu_button("PDF"))
      control.click!(at.menu_item(2).menu(1).menu_button("PDF"))
      
      save_location = control.wait_until_exists!(at.window("Save"), at.sheet(1) + control.base_location)
      save_dialog = create_save_dialog(control.name, save_location)
      save_dialog.save(filename)
      
      control.until_not_exists!(control.base_location) {
        # Weird, but sometimes the dialog "hangs around" and clicking this checkbox will make it go away.
        # Anyone who knows a better solution, please let me know!
        # This is for snow leopard
        control.click!(at.checkbox(1)) if control.exists?(at.checkbox(1))
      }
    end
  end
  
end
