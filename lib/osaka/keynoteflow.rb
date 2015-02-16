
module CommonFlows
    
  def self.keynote_combine_files(result_file, files_to_merge)
    keynote = Osaka::Keynote.new
    keynote.activate
    keynote.close_template_chooser_if_any
    keynote.raise_error_on_open_standard_windows("All Keynote windows must be closed before running this flow")
        
    files_to_merge = [files_to_merge].flatten
    keynote.open(files_to_merge.shift)
    keynote.select_all_slides
    keynote.save_as(result_file)
    
    
    files_to_merge.each { |file|
      combine_keynote = Osaka::Keynote.new
      combine_keynote.open(file)
      combine_keynote.select_all_slides
      combine_keynote.copy
      keynote.paste
      combine_keynote.close
      keynote.save
    }
    
    keynote.close
    keynote.quit
  end
  
  def self.keynote_combine_files_from_directory_sorted(result_file, directory = ".", pattern = /^.*\.key$/)
    files_in_directory = Dir.new(directory).entries
    files_in_directory.select! { |f| f =~ pattern }
    files_to_open = files_in_directory.collect { |f| File.join(directory, f)}
    keynote_combine_files(result_file, files_to_open.sort)
  end

  def self.keynote_yield_for_each_file(files)
    keynote = Osaka::Keynote.new
    keynote.activate
    keynote.close_template_chooser_if_any
    keynote.raise_error_on_open_standard_windows("All Keynote windows must be closed before running this flow")
    files = [files].flatten
    files.each { |file|
      keynote = Osaka::Keynote.new
      keynote.open(file)
      yield keynote
      keynote.close
    }
    keynote.quit
  end

  def self.keynote_combine_files_from_list(result_file, directory, keynote_files)
    files_with_path = keynote_files.collect { |f| File.join(directory, f)}
    missing_files = ""
    files_with_path.each { |f|
      if !File.exist?(f)
        missing_files += "\n" + f
      end
    }

    if missing_files.empty?
      keynote_combine_files(result_file, files_with_path)
    else
      puts "These files do not exist: " + missing_files
    end

  end

  def self.start_keynote
    keynote = Osaka::Keynote.new
    keynote.activate
    keynote.close_template_chooser_if_any
    keynote.raise_error_on_open_standard_windows("All Keynote windows must be closed before running this flow")
    keynote
  end

  def self.search_and_replace_presentation_text(keynote, find, replacement)
    keynote.find_replace_all(find, replacement)
    keynote.save
  end

end
