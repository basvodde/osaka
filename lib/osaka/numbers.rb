
module Osaka

  class Location
    def cell(name)
      create_location_with_added_name("cell", name)
    end

    def table(name)
      create_location_with_added_name("table", name)
    end
  end

  class Numbers < TypicalApplication

    def initialize
      super "Numbers"
    end

    def new_document
      super
      control.set_current_window(do_and_wait_for_new_standard_window {
        control.keystroke(:return)
      })
    end

    def self.create_document(filename, &block)
      numbers = Osaka::Numbers.new
      numbers.create_document(filename, &block)
    end

    def fill_cell(column, row, value)
      if (column > column_count)
        set_column_count(column)
      end
      control.tell("tell document 1; tell sheet 1; tell table 1; set value of cell #{column} of row #{row} to \"#{value}\"; end tell; end tell; end tell")
    end

    def column_count
      control.tell("tell document 1; tell sheet 1; tell table 1; get column count; end tell; end tell; end tell").to_i
    end

    def set_column_count(amount)
      control.tell("tell document 1; tell sheet 1; tell table 1; set column count to #{amount}; end tell; end tell; end tell")
    end

    def set_header_columns(column)
      control.click_menu_bar(at.menu_item(column.to_s).menu(1).menu_item("Header Columns"), "Table")
    end


  end
end
