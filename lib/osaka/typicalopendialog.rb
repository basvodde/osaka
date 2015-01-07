# encoding: utf-8
module Osaka

  class OpenDialogCantSelectFile < StandardError
  end

  class TypicalOpenDialog < TypicalFinderDialog

    def file_list_location
      if [:snow_leopard, :lion, :mountain_lion, :mavericks].include? control.mac_version
        at.outline(1).scroll_area(2).splitter_group(1).group(1)
      else
        at.outline(1).scroll_area(1).splitter_group(1).splitter_group(1).group(1)
      end
    end

    def text_field_location_from_row(row)
      at.text_field(1).ui_element(1).row(row) + file_list_location
    end

    def static_field_location_from_row(row)
      at.static_text(1).ui_element(1).row(row) + file_list_location
    end

    def greyed_out?(row)
      !control.exists?(text_field_location_from_row(row))
    end

    def click_open
      control.click(at.button("Open"))
    end

    def field_location_from_row(row)
      if (greyed_out?(row))
        static_field_location_from_row(row)
      else
        text_field_location_from_row(row)
      end
    end

    def select_file_by_row(row)
      raise(OpenDialogCantSelectFile, "Tried to select a file, but it either doesn't exist or is greyed out") if (greyed_out?(row))
      control.set!("selected", at.row(row) + file_list_location, true)
    end

    def amount_of_files_in_list
      amount_of_rows = control.get!("rows", file_list_location)
      amount_match_data = amount_of_rows.match(/.*row (\d) of/)
      amount_match_data.nil? ? 0 : amount_match_data[1].to_i
    end

    def filename_at(row)
      control.get!("value", field_location_from_row(row))
    end

    def select_file(filename)
      amount_of_files_in_list.times() { |row|
        if filename_at(row+1) == filename
          select_file_by_row(row+1)
          click_open
          return
        end
      }
    end
  end

end
