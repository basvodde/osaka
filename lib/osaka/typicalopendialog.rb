# encoding: utf-8
module Osaka
      
  class TypicalOpenDialog < TypicalFinderDialog
      
    def file_list_location
      at.outline(1).scroll_area(2).splitter_group(1).group(1)
    end
    
    def text_field_location_from_row(row)
      at.text_field(1).ui_element(1).row(row) + file_list_location
    end
      
    def amount_of_files_in_list
      amount_of_rows = control.get!("rows", file_list_location)
      amount_match_data = amount_of_rows.match(/.*row (\d) of/)
      amount_match_data.nil? ? 0 : amount_match_data[1].to_i 
    end
    
    def filename_at(row)
      control.get!("value", text_field_location_from_row(row))
    end
      
    def select_file(filename)
      amount_of_files = amount_of_files_in_list
      filename_at(1)
      select_filename_at(1)
      open
    end
  end  

end