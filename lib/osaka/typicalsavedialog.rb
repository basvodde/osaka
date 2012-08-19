# encoding: utf-8
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :control

    def initialize(application_name, own_location)
      @control = Osaka::RemoteControl.new(application_name, own_location)
    end
  
    def set_filename(filename)
      control.set("value", at.text_field(1), filename)
    end
  
    def set_folder(pathname)
      control.keystroke("g", [ :command, :shift ]).wait_until_exists(at.sheet(1))
      control.set("value", at.text_field(1).sheet(1), pathname)
      control.click(at.button("Go").sheet(1)).wait_until_not_exists(at.sheet(1))
    end
  
    def click_save
      control.click(at.button("Save")).wait_until_not_exists(control.base_location)
    end
  
    def save(filename)
      set_filename(File.basename(filename))
      set_folder(File.dirname(filename))  unless File.dirname(filename) == "."
      click_save
    end

  end  

end