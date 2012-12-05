# encoding: utf-8

module Osaka
  
  class Preview < TypicalApplication
    
    attr_accessor :control
    
    def initialize
      super "Preview"
    end
    
    def pdf_content
      control.get!("value", at.static_text(1).scroll_area(1).splitter_group(1))
    end
    
    def open(filename)
      control.click_menu_bar(at.menu_item("Open…"), "File").wait_until_exists(at.window("Open"))
      new_window = do_and_wait_for_new_window {
        select_file_from_open_dialog(filename, at.window("Open"))
      }
      control.set_current_window(new_window)
    end
    
  end
end