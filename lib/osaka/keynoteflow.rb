
module CommonFlows
    
  def self.keynote_combine_files(result_file, files_to_merge)
    keynote = Osaka::Keynote.new
    keynote.activate
    keynote.raise_error_on_open_standard_windows("All Keynote windows must be closed before running this flow")
        
    files_to_merge = [files_to_merge].flatten
    keynote.open(files_to_merge.shift)
    keynote.light_table_view
    keynote.save_as(result_file)
    
    
    files_to_merge.each { |file|
      combine_keynote = Osaka::Keynote.new
      combine_keynote.open(file)
      combine_keynote.select_all_slides
      combine_keynote.copy
      combine_keynote.close
      keynote.select_all_slides
      keynote.paste
    }
    
    keynote.save
    keynote.close
    keynote.quit
  end
  
  def self.keynote_combine_files_from_directory_sorted(result_file, directory = ".", pattern = /^.*\.key$/)
    files_in_directory = Dir.new(directory).entries
    files_in_directory.select! { |f| f =~ pattern }
    files_to_open = files_in_directory.collect { |f| File.join(directory, f)}
    keynote_combine_files(result_file, files_to_open.sort)
  end
   
end
