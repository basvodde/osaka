
module CommonFlows
  def self.keynote_combine_files(result_file, files_to_merge)
    keynote = Osaka::Keynote.new
    files_to_merge = [files_to_merge].flatten
    keynote.open(files_to_merge.shift)
    keynote.save_as(result_file)
    
    files_to_merge.each { |file|
      combine_keynote = Osaka::Keynote.new
      combine_keynote.open(file)
      combine_keynote.select_all_slides
      combine_keynote.copy
      keynote.select_all_slides
      keynote.paste
      combine_keynote.close
    }
    
    keynote.save
    keynote.quit
  end
  
  def self.keynote_combine_files_from_directory_sorted(result_file, directory = ".", pattern = /^.*\.key$/)
    files_in_directory = Dir.new(directory).entries
    files_in_directory.select! { |f| f =~ pattern }
    files_to_open = files_in_directory.collect { |f| File.join(directory, f)}
    keynote_combine_files(result_file, files_to_open.sort)
  end
end