# encoding: utf-8
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :control

    def initialize(self_location, control)
      @self_location = self_location
      @control = control.clone
      @control.set_current_window("") if self_location.has_top_level_element?
    end
  
    def set_filename(filename)
      control.set("value", at.text_field(1) + @self_location, filename)
    end
  
    def set_folder(pathname)
      control.keystroke("g", [ :command, :shift ]).wait_until_exists(at.sheet(1) + @self_location)
      control.set("value", at.text_field(1).sheet(1) + @self_location, pathname)
      control.click(at.button("Go").sheet(1) + @self_location).wait_until_not_exists(at.sheet(1) + @self_location)
    end
  
    def click_save
      control.click(at.button("Save") + @self_location).wait_until_not_exists(@self_location)
    end
  
    def save(filename)
      set_filename(File.basename(filename))
      set_folder(File.dirname(filename))  unless File.dirname(filename) == "."
      click_save
    end

  end  

end