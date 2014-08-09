# encoding: utf-8
module Osaka
      
  class TypicalSaveDialog < TypicalFinderDialog

    def click_save
      control.click(at.button("Save")).wait_until_not_exists(control.base_location)
    end
  
    def set_filename(filename)
      control.set("value", at.text_field(1), filename)
    end

    def save(filename)
      set_folder(File.dirname(filename))
      set_filename(File.basename(filename))
      click_save
    end

  end  

end
