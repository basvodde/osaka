
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :wrapper

    def initialize(location, wrapper)
      @location = location
      @wrapper = wrapper
    end
  
    def set_filename(filename)
      @wrapper.set("value", "text field 1 of #{@location}", filename)
    end
  
    def set_folder(pathname)
      @wrapper.keystroke("g", [ :command, :shift ]).wait_until.exists("sheet 1 of #{@location}")
      @wrapper.set("value", "text field 1 of sheet 1 of #{@location}", pathname)
      @wrapper.click("button \"Go\" of sheet 1 of #{@location}").wait_until.not_exists("sheet 1 of #{@location}")
    end
  
    def click_save
      @wrapper.click("button \"Save\" of #{@location}").wait_until.not_exists("#{@location}")
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
      TypicalSaveDialog.new(location, app)
    end

    def save_as_pdf(filename)
      @wrapper.click!("menu button \"PDF\" of #{@location}").wait_until!.exists("menu 1 of menu button \"PDF\" of #{@location}")
      @wrapper.click!("menu item 2 of menu 1 of menu button \"PDF\" of #{@location}").wait_until!.exists('window "Save"')
      save_dialog = create_save_dialog("window \"Save\"", @wrapper)
      save_dialog.save(filename)
      
      @wrapper.until!.not_exists(@location) {
        # Weird, but sometimes the dialog "hangs around" and clicking this checkbox will make it go away.
        # Anyone who knows a better solution, please let me know!
        @wrapper.click!('checkbox 1 of window "Print"')
      }
    end
  end
  
  class ApplicationInfo

    attr_reader :name

    def initialize(script_info)
      @name = script_info.match(/name:(.+?), creation date/)[1]
    end
    
  end

  class TypicalApplication
  
    attr_accessor :wrapper
  
    def initialize(name)
      @name = name
      @wrapper = ApplicationWrapper.new(name)
    end
    
    def get_info
      script_info = @wrapper.tell("get info for (path to application \"#{@name}\")")
      ApplicationInfo.new(script_info)
    end
  
    def open (filename)
      abolutePathFileName = File.absolute_path(filename)
      @wrapper.tell("open \"#{abolutePathFileName}\"")
    end

    def wait_for_window_and_dialogs_to_close(option)
      if (option != :user_chose)
        @wrapper.until!.not_exists("window \"#{wrapper.window}\"") {
          if (@wrapper.check!.exists("sheet 1 of window \"#{wrapper.window}\""))
            @wrapper.click!("button 2 of sheet 1 of window \"#{wrapper.window}\"")
          end
        }
      end
    end
      
    def quit(option = :user_chose)
      @wrapper.quit
      wait_for_window_and_dialogs_to_close(option)
    end

    def wait_for_new_window(original_window_list)
      latest_window_list = original_window_list
      while (original_window_list == latest_window_list)
        latest_window_list = @wrapper.window_list
      end
      (latest_window_list - original_window_list)[0]
    end
    
    def new_document
      window_list = @wrapper.window_list
      @wrapper.keystroke("n", :command)
      @wrapper.window = wait_for_new_window(window_list)
      @wrapper.focus
    end
    
    def save
      @wrapper.keystroke("s", :command)
    end
    
    def close(option = :user_chose)
      @wrapper.keystroke("w", :command)
      wait_for_window_and_dialogs_to_close(option)
    end
  
    def activate
      @wrapper.activate
    end
  
    def create_print_dialog(location)
      TypicalPrintDialog.new(location, @wrapper)
    end
  
    def print_dialog
      location = "sheet 1#{@wrapper.construct_window_info}"
      @wrapper.keystroke("p", :command).wait_until.exists(location)
      create_print_dialog(location)
    end
  
  end
end