
module Osaka
  
  class Keynote < TypicalApplication  
  
    def initialize
      super "Keynote"
    end

    def create_print_dialog(location)
      Osaka::KeynotePrintDialog.new(control.name, at.window("Print"))
    end
    
    def select_all_slides
      light_table_view
      select_all
    end

    def open (filename)
      abolutePathFileName = File.absolute_path(filename)
      new_window = do_and_wait_for_new_window {
        # Weird that keynote v6 open via osascript is flakey
        # was: control.tell("open \"#{abolutePathFileName}\"")
        # But now uses the run_command
        control.run_command "open #{abolutePathFileName}"
      }
      control.wait_until_exists(at.window(File.basename(filename)))
      control.set_current_window(new_window)
    end

    def light_table_view
      if control.exists?(at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1))
        control.click(at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1))
      end
    end

    def click_view_menu item
      control.click view_menu_bar_item item 
    end

    def view_menu_bar_item(item)
      at.menu_item(item).menu(1).menu_bar_item("View").menu_bar(1)
    end

    def edit_master_slides
       click_view_menu "Edit Master Slides"
    end

    def exit_master_slides
       click_view_menu "Exit Master Slides"
    end

    def exit_master_slides
      click_view_menu "Exit Master Slides"
    end

    def open_print_dialog
      control.keystroke("p", :command)
      location = at.sheet(1)
      control.wait_until_exists(location)
      create_dialog(KeynotePrintDialog, location)
    end      

    def print_pdf output_pdf, slides_per_page
      dialog = open_print_dialog
      dialog.use_page_margins
      dialog.slides_per_page slides_per_page
      # dialog.save_as_pdf output_pdf
    end


  end
end
