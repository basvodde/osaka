
module Osaka
  class PagesMailMergeDialog
    attr_accessor :wrapper, :location

    def initialize(location, wrapper)
      @location = location
      @wrapper = wrapper
    end
  
    def merge
      @wrapper.click!("button \"Merge\" of sheet 1 of window \"#{@wrapper.window}\"")
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
      @wrapper.click("pop up button 2 of #{@location}")
      @wrapper.wait_until!.exists("menu item #{value} of menu 1 of pop up button 2 of #{@location}")
      @wrapper.click!("menu item #{value} of menu 1 of pop up button 2 of #{@location}")
    end    
  end

  class Pages < TypicalApplication
  
    def initialize
      super "Pages"
    end
  
    def mail_merge
      @wrapper.system_event("tell menu bar 1; tell menu \"Edit\"; click menu item 20; end tell; end tell")
      @wrapper.wait_until.exists("button \"Merge\" of sheet 1 of window \"#{@wrapper.window}\"")
      PagesMailMergeDialog.new("sheet 1 of window\"#{@wrapper.window}\"", @wrapper)
    end
    
    def mail_merge_to_pdf(filename)
      mail_merge_dialog = mail_merge
      mail_merge_dialog.set_merge_to_printer
      print_dialog = mail_merge_dialog.merge
      print_dialog.save_as_pdf(filename)
    end
  
  end
end