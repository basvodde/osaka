require 'tmpdir'
require 'osaka'

describe "Integration tests for Keynote and Common Flows" do
  
  it "Should be able to do a combine with just one file" do
    
    # Osaka::ScriptRunner.enable_debug_prints(:short_html)
    
    assets_directory =  File.join(File.dirname(__FILE__), "assets")
    
    keynote_file = File.join(assets_directory, "01_first_slides.key")
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files(results_file, keynote_file)
      File.exists?(results_file).should == true
    }
  end
  
  it "Should be able to combine multiple files" do
    assets_directory =  File.join(File.dirname(__FILE__), "assets")
    
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files_from_directory_sorted(results_file, assets_directory)
      File.exists?(results_file).should == true
    }
    
  end
  
end