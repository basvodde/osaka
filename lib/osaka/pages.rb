
module Osaka
  class PagesMailMergeDialog
    attr_accessor :control, :location

    def initialize(location, control)
      @location = location
      @control = control
    end
  
    def merge
      control.click!(at.button("Merge").sheet(1))
      print_dialog_location = at.window("Print")
      control.wait_until_exists!(at.menu_button("PDF") + print_dialog_location)
      TypicalPrintDialog.new(control.name, print_dialog_location)
    end
        
    def set_merge_to_new_document
      set_merge_to_document_printer(1)
    end
    
    def set_merge_to_printer
      set_merge_to_document_printer(2)
    end
    
  private
    def set_merge_to_document_printer(value)
      control.click(at.pop_up_button(2).sheet(1))
      control.wait_until_exists!(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
      control.click!(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
    end    
  end

  class Pages < TypicalApplication
  
    def initialize
      super "Pages"
    end
  
    def mail_merge
      control.click_menu_bar(at.menu_item(20), "Edit")
      control.wait_until_exists(at.button("Merge").sheet(1))
      PagesMailMergeDialog.new(at.sheet(1), control)
    end
    
    def mail_merge_to_pdf(filename)
      mail_merge_dialog = mail_merge
      mail_merge_dialog.set_merge_to_printer
      print_dialog = mail_merge_dialog.merge
      print_dialog.save_as_pdf(filename)
    end
  
  end
end