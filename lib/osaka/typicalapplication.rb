
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :wrapper

    def initialize(parent, wrapper)
      @parent = parent
      @wrapper = wrapper.clone
      @wrapper.set_current_window("Save")
    end
  
    def set_filename(filename)
      @wrapper.set("value", at.text_field(1) + @parent, filename)
    end
  
    def set_folder(pathname)
      @wrapper.keystroke("g", [ :command, :shift ]).wait_until.exists(at.sheet(1) + @parent)
      @wrapper.set("value", at.text_field(1).sheet(1) + @parent, pathname)
      @wrapper.click(at.button("Go").sheet(1) + @parent).wait_until.not_exists(at.sheet(1) + @parent)
    end
  
    def click_save
      @wrapper.click(at.button("Save") + @parent).wait_until.not_exists(@parent)
    end
  
    def save(filename)
      set_filename(File.basename(filename))
      set_folder(File.dirname(filename))  unless File.dirname(filename) == "."
      click_save
    end

  end  

  class TypicalPrintDialog
    attr_accessor :wrapper

    def initialize(parent, wrapper)
      @parent = parent
      @wrapper = wrapper
    end
  
    def create_save_dialog(location, app)
      TypicalSaveDialog.new(location, app)
    end

    def save_as_pdf(filename)
      @wrapper.click!(at.menu_button("PDF") + @parent).wait_until!.exists(at.menu(1).menu_button("PDF") + @parent)
      @wrapper.click!(at.menu_item(2).menu(1).menu_button("PDF") + @parent).wait_until!.exists('window "Save"')
      save_dialog = create_save_dialog(at.window("Save"), @wrapper)
      save_dialog.save(filename)
      
      @wrapper.until!.not_exists(@parent) {
        # Weird, but sometimes the dialog "hangs around" and clicking this checkbox will make it go away.
        # Anyone who knows a better solution, please let me know!
        @wrapper.click!(at.checkbox(1).window("Print"))
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
      @wrapper.set_current_window(File.basename(filename))
    end

    def wait_for_window_and_dialogs_to_close(option)
      if (option != :user_chose)
        @wrapper.until!.not_exists(@wrapper.current_window_location) {
          close_dialog_sheet_with_dont_save
        }
      end
    end

    def wait_for_application_to_quit(option)
      if (option != :user_chose)
        while @wrapper.running?
          close_dialog_sheet_with_dont_save
        end
      end
    end
    
    def close_dialog_sheet_with_dont_save
      if (@wrapper.check!.exists(at.sheet(1)))
        @wrapper.click!(at.button(2).sheet(1))
      end
    end
    
    def quit(option = :user_chose)
      if @wrapper.running?
        @wrapper.quit
        wait_for_application_to_quit(option)
      end
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
      @wrapper.set_current_window(wait_for_new_window(window_list))
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
    
    def running?
      @wrapper.running?
    end
  
    def create_print_dialog(location)
      TypicalPrintDialog.new(location, @wrapper)
    end
  
    def print_dialog
      @wrapper.keystroke("p", :command).wait_until.exists(at.sheet(1))
      create_print_dialog(at.sheet(1))
    end
  
  end
end