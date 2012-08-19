# encoding: utf-8
module Osaka
  
  class ApplicationInfo

    attr_reader :name

    def initialize(script_info)
      @name = script_info.match(/name:(.+?), creation date/)[1]
    end    
  end

  class TypicalApplication
  
    attr_accessor :control
  
    def initialize(name)
      @name = name
      @control = RemoteControl.new(name)
    end
    
    def initialize_copy(other)
      super
      @control = other.control.clone
    end
    
    def get_info
      script_info = control.tell("get info for (path to application \"#{@name}\")")
      ApplicationInfo.new(script_info)
    end
  
    def open (filename)
      abolutePathFileName = File.absolute_path(filename)
      control.tell("open \"#{abolutePathFileName}\"")
      control.set_current_window(File.basename(filename))
    end

    def wait_for_window_and_dialogs_to_close(option)
      if (option != :user_chose)
        control.until_not_exists!(control.base_location) {
          close_dialog_sheet_with_dont_save
        }
      end
    end

    def wait_for_application_to_quit(option)
      if (option != :user_chose)
        while control.running?
          close_dialog_sheet_with_dont_save
        end
      end
    end
    
    def close_dialog_sheet_with_dont_save
      if (control.exists?(at.sheet(1)))
        control.click!(at.button("Don’t Save").sheet(1))
      end
    end
    
    def quit(option = :user_chose)
      if control.running?
        control.quit
        wait_for_application_to_quit(option)
      end
    end

    def do_and_wait_for_new_window
      control.activate
      latest_window_list = original_window_list = control.window_list
      yield
      while (original_window_list == latest_window_list)
        latest_window_list = control.window_list
      end
      (latest_window_list - original_window_list)[0]
    end
    
    def new_document
      control.set_current_window(do_and_wait_for_new_window {
        control.keystroke("n", :command)
      })
      control.focus
    end
    
    def duplicate_available?
      control.exists?(at.menu_item("Duplicate").menu(1).menu_bar_item("File").menu_bar(1))
    end
    
    def duplicate
      unless duplicate_available?
        raise(Osaka::VersioningError, "MacOS Versioning Error: Duplicate is not available on this Mac version")
      end
      new_window = do_and_wait_for_new_window {
        control.keystroke("s", [:command, :shift])
      }
      new_instance = clone
      new_instance.control.set_current_window(do_and_wait_for_new_window {
        sleep(0.4) # This sleep is added because mountain lion keynote crashes without it!
        control.keystroke!(:return)
      })
      
      new_instance
    end
    
    def save
      control.keystroke("s", :command)
    end
    
    def save_pops_up_dialog?
      control.exists?(at.menu_item("Save…").menu(1).menu_bar_item("File").menu_bar(1))
    end
    
    def save_dialog
      if save_pops_up_dialog?
        save
        control.wait_until_exists(at.sheet(1))
      else
        control.keystroke("s", [:command, :shift]).wait_until_exists(at.sheet(1))
      end
      create_save_dialog(at.sheet(1) + control.base_location)
    end
    
    def save_as(filename)
      if duplicate_available?
        new_instance = duplicate        
        close        
        @control = new_instance.control.clone
      end      
      dialog = save_dialog
      dialog.save(filename)
      control.set_current_window(File.basename(filename))
    end
    
    def close(option = :user_chose)
      control.keystroke("w", :command)
      wait_for_window_and_dialogs_to_close(option)
    end
  
    def activate
      control.activate
    end
    
    def focus
      control.focus
    end
    
    def running?
      control.running?
    end
  
    def copy
      control.keystroke("c", :command)
    end

    def paste
      control.keystroke("v", :command)
    end

    def cut
      control.keystroke("x", :command)
    end

    def select_all
      control.keystroke("a", :command)
    end
    
    def create_print_dialog(location)
      TypicalPrintDialog.new(control.name, location)
    end
    
    def create_save_dialog(location)
      TypicalSaveDialog.new(control.name, location)
    end
  
    def print_dialog
      control.keystroke("p", :command).wait_until_exists(at.sheet(1))
      create_print_dialog(at.sheet(1) + control.base_location)
    end
  
  end
end