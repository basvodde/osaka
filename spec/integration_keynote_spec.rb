require 'tmpdir'
require 'osaka'

describe "Integration tests for Keynote and Common Flows", :integration => true do

  before(:each) do
    @assets_directory =  File.join(File.dirname(__FILE__), "assets")
  end
    
  it "Should be able to do a combine with just one file" do
    
    keynote_file = File.join(@assets_directory, "01_first_slides.key")
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files(results_file, keynote_file)
      expect(File.exists?(results_file)).to eq true
    }
  end
  
  it "Should be able to combine multiple files" do
    
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files_from_directory_sorted(results_file, @assets_directory)
      expect(File.exists?(results_file)).to eq true
    }  
  end
  
  it "Should exit with message if files are open" do
    
    keynote_file = File.join(@assets_directory, "01_first_slides.key")
    keynote = Osaka::Keynote.new
    keynote.open(keynote_file)

    expect {
      CommonFlows.keynote_combine_files(nil, keynote_file)
    }.to raise_error(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")

    keynote.close
  end
  
end
