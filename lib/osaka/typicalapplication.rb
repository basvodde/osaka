
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :wrapper

    def initialize(location, wrapper)
      @location = location
      @wrapper = wrapper
    end
  
    def set_filename(filename)
      @wrapper.set("value of text field 1 of #{@location}", filename)
    end
  
    def set_folder(pathname)
      @wrapper.keystroke_and_wait_until_exists("g", [ :command, :shift ], "sheet 1 of #{@location}")
      @wrapper.set("value of text field 1 of sheet 1 of #{@location}", pathname)
      @wrapper.click_and_wait_until_not_exists("button \"Go\" of sheet 1 of #{@location}", "sheet 1 of #{@location}")
    end
  
    def click_save
      @wrapper.click_and_wait_until_not_exists("button \"Save\"  of #{@location}", "#{@location}")
    end
  
    def save(filename)
      set_filename(File.basename(filename))
      set_folder(File.dirname(filename))  unless File.dirname(filename) == "."
      click_save
    end

  end  

  class TypicalPrintDialog
    attr_accessor :wrapper

    def initialize(location, wrapper)
      @location = location
      @wrapper = wrapper
    end
  
    def create_save_dialog(location, app)
      GenericSaveDialog.new(location, app)
    end

    def save_as_pdf(filename)
      @wrapper.click_and_wait_until_exists!("menu button \"PDF\" of #{@location}", "menu 1 of menu button \"PDF\" of #{@location}")
      @wrapper.click_and_wait_until_exists!("menu item 2 of menu 1 of menu button \"PDF\" of #{@location}", 'window "Save"')
      save_dialog = create_save_dialog("window \"Save\"", @wrapper)
      save_dialog.save(filename)
      @wrapper.wait_until_not_exists(@location)
    end
  end

  class TypicalApplication
  
    attr_accessor :wrapper
  
    def initialize(name)
      @wrapper = ApplicationWrapper.new(name)
    end
  
    def open (filename)
      abolutePathFileName = File.absolute_path(filename)
      @wrapper.tell("open \"#{abolutePathFileName}\"")
    end
  
    def quit
      @wrapper.quit
    end

    def save
      @wrapper.keystroke("s", :command)
    end
  
    def activate
      @wrapper.activate
    end
  
    def create_print_dialog(location)
      TypicalPrintDialog.new(location, @wrapper)
    end
  
    def print_dialog
      location = "sheet 1 of window 1"
      @wrapper.keystroke_and_wait_until_exists("p", :command, location)
      create_print_dialog(location)
    end
  
  end
end