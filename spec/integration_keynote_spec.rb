require 'tmpdir'
require 'osaka'

describe "Integration tests for Keynote and Common Flows", :integration => true do

  def mac_version
    control = Osaka::RemoteControl.new(nil)
    control.mac_version
  end

  before(:each) do
    dir = (mac_version == :mavericks ? "assets/key-v6.2" : "assets/key-09")
    @assets_directory =  File.join(File.dirname(__FILE__), dir)
  end

  it "Should be able to do a combine with just one file" do
    
    keynote_file = File.join(@assets_directory, "01_first_slides.key")
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files(results_file, keynote_file)
      expect(File.exists?(results_file)).to be(true)
    }
  end
  
  it "Should be able to combine multiple files" do
    
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files_from_directory_sorted(results_file, @assets_directory)
      expect(File.exists?(results_file)).to be(true)
    }  
  end
  
  it "Should be able to combine multiple files with keynote '09" do
    if mac_version == :mavericks
      @assets_directory =  File.join(File.dirname(__FILE__), "assets/key-09")
      Dir.mktmpdir { |dir|
        results_file = File.join(dir, "results.key")
        CommonFlows.keynote_combine_files_from_directory_sorted(results_file, @assets_directory)
        expect(File.exists?(results_file)).to be(true)
      }  
    end
  end
  
  it "Should be able to combine multiple files from a file list" do
    
    Dir.mktmpdir { |dir|
      results_file = File.join(dir, "results.key")
      CommonFlows.keynote_combine_files_from_list(results_file, @assets_directory, ["01_first_slides.key", "02_second_slides.key", "03_third_slides.key"])
      expect(File.exists?(results_file)).to be(true)
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

  it "Should report non-existant files and terminate" do
    bad_file_name = "02_typo_slides.key"
    CommonFlows.should_receive(:output).with("These files do not exist: \n" + File.join(@assets_directory, bad_file_name))
    Dir.mktmpdir { |dir|
      CommonFlows.keynote_combine_files_from_list(nil, @assets_directory, ["01_first_slides.key", bad_file_name, "03_third_slides.key"])
    }  
  end
    
end