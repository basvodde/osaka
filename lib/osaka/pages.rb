
module Osaka

  class PagesError < RuntimeError
  end

  class PagesMailMergeDialog
    attr_accessor :control, :location

    def initialize(location, control)
      @location = location
      @control = control
    end

    def merge
      control.click!(at.button("Merge").sheet(1))
      print_dialog_location = at.window("Print")
      control.wait_until_exists!(at.menu_button("PDF") + print_dialog_location)
      TypicalPrintDialog.new(control.name, print_dialog_location)
    end

    def set_merge_to_new_document
      set_merge_to_document_printer(1)
    end

    def set_merge_to_printer
      set_merge_to_document_printer(2)
    end

  private
    def set_merge_to_document_printer(value)
      control.click(at.pop_up_button(2).sheet(1))
      control.wait_until_exists!(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
      control.click!(at.menu_item(value).menu(1).pop_up_button(2).sheet(1))
    end
  end

  class PagesInspector
    attr_accessor :control
    attr_accessor :location_symbol_map

    def initialize(application_name, own_location)
      @control = Osaka::RemoteControl.new(application_name, own_location)
      @location_symbol_map = {}
      @location_symbol_map[:document] = 1
      @location_symbol_map[:layout] = 2
      @location_symbol_map[:wrap] = 3
      @location_symbol_map[:text] = 4
      @location_symbol_map[:graphic] = 5
      @location_symbol_map[:metrics] = 6
      @location_symbol_map[:table] = 7
      @location_symbol_map[:chart] = 8
      @location_symbol_map[:link] = 9
      @location_symbol_map[:quicktime] = 10
    end

    def get_location_from_symbol(inspector_name)
      at.radio_button(@location_symbol_map[inspector_name]).radio_group(1)
    end

    def select_inspector(inspector)
      control.click(get_location_from_symbol(inspector))
      control.wait_until_exists(at.window(inspector.to_s))
      control.set_current_window(inspector.to_s)
    end

    def change_mail_merge_source
      select_inspector(:link)
      control.click(at.radio_button(3).tab_group(1).group(1)).wait_until_exists(at.button("Choose...").tab_group(1).group(1))
      control.click(at.button("Choose...").tab_group(1).group(1))
    end

  end

  class Pages < TypicalApplication

    def initialize
      super "Pages"
    end

    def type(text)
      control.keystroke(text)
    end

    def self.create_document(filename, &block)
      pages = Osaka::Pages.new
      pages.create_document(filename, &block)
    end

    def new_document
      super
      if control.window_list.include? "Template Chooser"
        control.set_current_window(do_and_wait_for_new_standard_window {
          control.click(at.button("Choose").window("Template Chooser"))
        })
      end
    end

    def set_mail_merge_document(filename)
      inspector.change_mail_merge_source
      control.wait_until_exists(at.sheet(1))
      open_dialog = do_and_wait_for_new_window {
        control.click(at.radio_button("Numbers Document:").radio_group(1).sheet(1))
      }
      select_file_from_open_dialog(filename, at.window(open_dialog))
      if (control.exists?(at.sheet(1).sheet(1)))
        raise(PagesError, "Setting Mail Merge numbers file failed")
      end
      control.click(at.button("OK").sheet(1))
    end

    def mail_merge_field(field_name)
      control.click_menu_bar(at.menu_item(field_name).menu(1).menu_item("Merge Field"), "Insert")
    end

    def mail_merge
      control.click_menu_bar(at.menu_item(20), "Edit")
      control.wait_until_exists(at.button("Merge").sheet(1))
      PagesMailMergeDialog.new(at.sheet(1), control)
    end

    def mail_merge_to_pdf(filename)
      mail_merge_dialog = mail_merge
      mail_merge_dialog.set_merge_to_printer
      print_dialog = mail_merge_dialog.merge
      print_dialog.save_as_pdf(filename)
    end

    def inspector
      if !control.exists?(at.menu_item("Show Inspector").menu(1).menu_bar_item("View").menu_bar(1))
        control.click_menu_bar(at.menu_item("Hide Inspector"), "View")
        control.wait_until_exists(at.menu_item("Show Inspector").menu(1).menu_bar_item("View").menu_bar(1))
      end

      window_name = do_and_wait_for_new_window {
        control.click_menu_bar(at.menu_item("Show Inspector"), "View")
      }
      PagesInspector.new(control.name, at.window(window_name))
    end

  end
end
