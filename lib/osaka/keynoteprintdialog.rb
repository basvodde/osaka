module Osaka
  
  class KeynotePrintDialog < TypicalPrintDialog
    attr_accessor :control

    def initialize(application_name, own_location)
      @control = Osaka::RemoteControl.new(application_name, own_location)
    end

    def margins(value)
      element = at.checkbox("Use page margins").group(3)
      control.set_checkbox(element, value)
    end

    def backgrounds(value)
      element = at.checkbox("Print slide backgrounds")
      control.set_checkbox(element, value)
    end

    def animations(value)
      element = at.checkbox("Print each stage of builds")
      control.set_checkbox(element, value)
    end

    def save_pdf_course_notes(filename = nil)
      open_save_as_pdf_dialog
      if filename
        control.set("value", at.text_field(1).sheet(1) , filename)
        sleep 1
      end
      save_pdf
    end

    def open_save_as_pdf_dialog
      control.keystroke("d", :command)
      sleep 1
    end

    def save_pdf
      control.click(at.button("Save").sheet(1))
    end

    def cancel
      control.click(at.button("Cancel"))
    end
  end
end

