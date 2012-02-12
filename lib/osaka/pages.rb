
module Osaka
  class PagesMailMergeDialog
    attr_accessor :wrapper

    def initialize(wrapper)
      @wrapper = wrapper
    end
  
    def merge
      @wrapper.click!('button "Merge" of sheet 1 of window 1')
      print_dialog_location = 'window "Print"' 
      @wrapper.wait_until_exists!("menu button \"PDF\" of #{print_dialog_location}")
      TypicalPrintDialog.new(print_dialog_location, @wrapper)
    end
  
  end

  class Pages < TypicalApplication
  
    def initialize
      super "Pages"
    end
  
    def mail_merge
      @wrapper.system_event("tell menu bar 1; tell menu \"Edit\"; click menu item 20; end tell; end tell")
      @wrapper.wait_until_exists('button "Merge" of sheet 1 of window 1')
      PagesMailMergeDialog.new(@wrapper)
    end
    
    def mail_merge_to_pdf(filename)
      mail_merge_dialog = mail_merge
      print_dialog = mail_merge_dialog.merge
      print_dialog.save_as_pdf(filename)
    end
  
  end
end