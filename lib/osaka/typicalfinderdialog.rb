# encoding: utf-8
module Osaka

  class TypicalFinderDialog
    attr_accessor :control

    def initialize(application_name, own_location)
      @control = Osaka::RemoteControl.new(application_name, own_location)
    end
  
    def set_folder(pathname)
      return if pathname == "."
      control.keystroke("g", [ :command, :shift ]).wait_until_exists(at.sheet(1))
      control.set("value", at.text_field(1).sheet(1), pathname)
      sleep(1) # Seems this must be here due to the sucking Apple UI. Not found something else to wait for!
      control.click(at.button("Go").sheet(1)).wait_until_not_exists(at.sheet(1))
    end
  end
  
end
