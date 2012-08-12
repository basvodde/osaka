# encoding: utf-8
module Osaka
  
  class TypicalSaveDialog
    attr_accessor :wrapper

    def initialize(self_location, wrapper)
      @self_location = self_location
      @wrapper = wrapper.clone
      @wrapper.set_current_window("") if self_location.has_top_level_element?
    end
  
    def set_filename(filename)
      @wrapper.set("value", at.text_field(1) + @self_location, filename)
    end
  
    def set_folder(pathname)
      @wrapper.keystroke("g", [ :command, :shift ]).wait_until_exists(at.sheet(1) + @self_location)
      @wrapper.set("value", at.text_field(1).sheet(1) + @self_location, pathname)
      @wrapper.click(at.button("Go").sheet(1) + @self_location).wait_until_not_exists(at.sheet(1) + @self_location)
    end
  
    def click_save
      @wrapper.click(at.button("Save") + @self_location).wait_until_not_exists(@self_location)
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
      @wrapper.click!(at.menu_button("PDF") + @parent).wait_until_exists!(at.menu(1).menu_button("PDF") + @parent)
      @wrapper.click!(at.menu_item(2).menu(1).menu_button("PDF") + @parent)
      
      save_location = @wrapper.wait_until_exists!(at.window("Save"), at.sheet(1).window("Print"))      
      save_dialog = create_save_dialog(save_location, @wrapper)
      save_dialog.save(filename)
      
      @wrapper.until_not_exists!(@parent) {
        # Weird, but sometimes the dialog "hangs around" and clicking this checkbox will make it go away.
        # Anyone who knows a better solution, please let me know!
        # This is for snow leopard
        @wrapper.click!(at.checkbox(1) + @parent) if @wrapper.exists(at.checkbox(1) + @parent)
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
    
    def initialize_copy(other)
      super
      @wrapper = other.wrapper.clone
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
        @wrapper.until_not_exists!(@wrapper.current_window_location) {
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
      if (@wrapper.exists(at.sheet(1)))
        @wrapper.click!(at.button("Don’t Save").sheet(1))
      end
    end
    
    def quit(option = :user_chose)
      if @wrapper.running?
        @wrapper.quit
        wait_for_application_to_quit(option)
      end
    end

    def do_and_wait_for_new_window
      @wrapper.activate
      latest_window_list = original_window_list = @wrapper.window_list
      yield
      while (original_window_list == latest_window_list)
        latest_window_list = @wrapper.window_list
      end
      (latest_window_list - original_window_list)[0]
    end
    
    def new_document
      @wrapper.set_current_window(do_and_wait_for_new_window {
        @wrapper.keystroke("n", :command)
      })
      @wrapper.focus
    end
    
    def duplicate_available?
      @wrapper.exists(at.menu_item("Duplicate").menu(1).menu_bar_item("File").menu_bar(1))
    end
    
    def duplicate
      unless duplicate_available?
        raise(Osaka::VersioningError, "MacOS Versioning Error: Duplicate is not available on this Mac version")
      end
      new_window = do_and_wait_for_new_window {
        @wrapper.keystroke("s", [:command, :shift])
      }
      new_instance = clone
      new_instance.wrapper.set_current_window(do_and_wait_for_new_window {
        sleep(0.4) # This sleep is added because mountain lion keynote crashes without it!
        @wrapper.keystroke!(:return)
      })
      
      new_instance
    end
    
    def save
      @wrapper.keystroke("s", :command)
    end
    
    def save_pops_up_dialog?
      @wrapper.exists(at.menu_item("Save…").menu(1).menu_bar_item("File").menu_bar(1))
    end
    
    def save_dialog
      if save_pops_up_dialog?
        save
        @wrapper.wait_until_exists(at.sheet(1))
      else
        @wrapper.keystroke("s", [:command, :shift]).wait_until_exists(at.sheet(1))
      end
      create_save_dialog(at.sheet(1))
    end
    
    def save_as(filename)
      if duplicate_available?
        new_instance = duplicate
        close
        @wrapper = new_instance.wrapper.clone
      end
      dialog = save_dialog
      dialog.save(filename)
      @wrapper.set_current_window(File.basename(filename))
    end
    
    def close(option = :user_chose)
      @wrapper.keystroke("w", :command)
      wait_for_window_and_dialogs_to_close(option)
    end
  
    def activate
      @wrapper.activate
    end
    
    def focus
      @wrapper.focus
    end
    
    def running?
      @wrapper.running?
    end
  
    def copy
      @wrapper.keystroke("c", :command)
    end

    def paste
      @wrapper.keystroke("v", :command)
    end

    def cut
      @wrapper.keystroke("x", :command)
    end

    def select_all
      @wrapper.keystroke("a", :command)
    end
    
    def create_print_dialog(location)
      TypicalPrintDialog.new(location, @wrapper)
    end
    
    def create_save_dialog(location)
      TypicalSaveDialog.new(location, @wrapper)
    end
  
    def print_dialog
      @wrapper.keystroke("p", :command).wait_until_exists(at.sheet(1))
      create_print_dialog(at.sheet(1))
    end
  
  end
end