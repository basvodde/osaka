
require "osaka"

describe "Common flows in keynote" do
  
  let(:mock_keynote) { double("First keynote")}

  def should_get_started
    mock_keynote.should_receive(:activate)
    mock_keynote.should_receive(:close_template_chooser_if_any)
    mock_keynote.should_receive(:raise_error_on_open_standard_windows)
  end

  def should_create_output_file_from_input(input_file, result_file)
    mock_keynote.should_receive(:open).with(input_file)
    mock_keynote.should_receive(:select_all_slides)
    mock_keynote.should_receive(:save_as).with(result_file)
  end

  def  should_append_file(file) 
    another_keynote = double("keynote with " + file)
    Osaka::Keynote.should_receive(:new).and_return(another_keynote)
    another_keynote.should_receive(:open).with(file)
    another_keynote.should_receive(:select_all_slides)
    another_keynote.should_receive(:copy)
    mock_keynote.should_receive(:paste)
    another_keynote.should_receive(:close)
  end

  def should_shutdown
    mock_keynote.should_receive(:save)
    mock_keynote.should_receive(:close)
    mock_keynote.should_receive(:quit)
  end

  it "Should exit if keynote windows are already open" do
    Osaka::Keynote.should_receive(:new).and_return(mock_keynote)
    should_get_started
      .with("All Keynote windows must be closed before running this flow")
      .and_raise(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
    
    expect {
      CommonFlows.keynote_combine_files("result.key", "one_file.key")
    }.to raise_error(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
  end
  
  it "Should be able to combine just one single file" do
    Osaka::Keynote.should_receive(:new).and_return(mock_keynote)
    should_get_started
    should_create_output_file_from_input("one_file.key", "result.key")
    should_shutdown
    CommonFlows.keynote_combine_files("result.key", "one_file.key")
  end
  
  it "Should be able to combine multiple files in one result" do
    Osaka::Keynote.should_receive(:new).and_return(mock_keynote)  
    should_get_started
    should_create_output_file_from_input("one_file.key", "result.key")
    should_append_file("two_file.key")    
    should_append_file("three_file.key")    
    should_shutdown
    CommonFlows.keynote_combine_files("result.key", ["one_file.key", "two_file.key", "three_file.key"])    
  end
  
  it "Should be able to combine multiple files from one directory sorted" do
    files_in_dir = [".", "..", "one.key", "05_file.key", "02key.wrong", "another", "01hey.key", "last"]
    files_matching = ["./05_file.key", "./01hey.key", "./one.key"]
    Dir.should_receive(:new).with(".").and_return(files_in_dir)
    CommonFlows.should_receive(:keynote_combine_files).with("results.key", files_matching.sort)
    CommonFlows.keynote_combine_files_from_directory_sorted("results.key")    
  end

  it "Should be able to combine multiple files from one directory sorted with pattern" do
    files_in_dir = [".", "..", "05_file.key", "02key.wrong", "another", "01hey.key", "last"]
    files_in_dir_to_be_used = ["dirname/01hey.key", "dirname/05_file.key"]
    mocked_dir = double("Directory with keynote files")
    Dir.should_receive(:new).with("dirname").and_return(mocked_dir)
    mocked_dir.should_receive(:entries).and_return(files_in_dir)
    CommonFlows.should_receive(:keynote_combine_files).with("results.key", files_in_dir_to_be_used)
    CommonFlows.keynote_combine_files_from_directory_sorted("results.key", "dirname", /^\d+.*\.key$/)    
  end
  
  it "Should be able to open and close keynote files" do
    Osaka::Keynote.should_receive(:new).exactly(3).times.and_return(mock_keynote)
    should_get_started
    mock_keynote.should_receive(:open).with("file1.key")
    mock_keynote.should_receive(:close)
    mock_keynote.should_receive(:open).with("file2.key")
    mock_keynote.should_receive(:close)
    mock_keynote.should_receive(:quit)
    CommonFlows.keynote_open_yield_close(["file1.key", "file2.key"]) { |k| k.instance_of? Osaka::Keynote }
  end
  
  it "Should be able to search and replace strings in keynote files" do
  end
  
end