require 'tmpdir'
require 'osaka'

describe "Integration tests for Keynote and Common Flows" do
  
  it "Should be able to do a combine with just one file" do
   
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
    
    keynote_file = [File.join(assets_directory, "01_first_slides.key"), 
                    File.join(assets_directory, "02_second_slides.key"),
                    File.join(assets_directory, "03_third_slides.key") ]
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files(results_file, keynote_file)
      File.exists?(results_file).should == true
    }
    
  end
  
end