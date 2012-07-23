
module Osaka
  class PagesMailMergeDialog
    attr_accessor :wrapper, :location

    def initialize(location, wrapper)
      @location = location
      @wrapper = wrapper
    end
  
    def merge
      @wrapper.click!(at.button("Merge").sheet(1))
      print_dialog_location = 'window "Print"' 
      @wrapper.wait_until!.exists("menu button \"PDF\" of #{print_dialog_location}")
      TypicalPrintDialog.new(print_dialog_location, @wrapper)
    end
        
    def set_merge_to_new_document
      set_merge_to_document_printer(1)
    end
    
    def set_merge_to_printer
      set_merge_to_document_printer(2)
    end
    
  private
    def set_merge_to_document_printer(value)
      @wrapper.click(at.pop_up_button(2).sheet(1))
      @wrapper.wait_until!.exists(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
      @wrapper.click!(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
    end    
  end

  class Pages < TypicalApplication
  
    def initialize
      super "Pages"
    end
  
    def mail_merge
      @wrapper.click_menu_bar(at.menu_item(20), "Edit")
      # @wrapper.click!(at.menu_bar_item("Edit").menu_bar(1))
      # @wrapper.wait_until.exists(at.menu(1).menu_bar_item("Edit").menu_bar(1))
      # @wrapper.click!(at.menu_item(20).menu(1).menu_bar_item("Edit").menu_bar(1))
      @wrapper.wait_until.exists(at.button("Merge").sheet(1))
      PagesMailMergeDialog.new(at.sheet(1), @wrapper)
    end
    
    def mail_merge_to_pdf(filename)
      mail_merge_dialog = mail_merge
      mail_merge_dialog.set_merge_to_printer
      print_dialog = mail_merge_dialog.merge
      print_dialog.save_as_pdf(filename)
    end
  
  end
end