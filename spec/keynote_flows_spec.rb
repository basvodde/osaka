
require "osaka"

describe "Common flows in keynote" do
  
  let(:mock_keynote) { double("First keynote")}

  def should_get_new_keynote_then_return_mock mock = mock_keynote
    expect(Osaka::Keynote).to receive(:new).and_return(mock)
  end

  def should_get_started
    expect(mock_keynote).to receive(:activate)
    expect(mock_keynote).to receive(:close_template_chooser_if_any)
    expect(mock_keynote).to receive(:raise_error_on_open_standard_windows)
  end

  def should_create_output_file_from_input(input_file, result_file)
    expect(mock_keynote).to receive(:open).with(input_file)
    expect(mock_keynote).to receive(:select_all_slides)
    expect(mock_keynote).to receive(:save_as).with(result_file)
  end

  def  should_append_file(file) 
    another_keynote = double("keynote with " + file)
    should_get_new_keynote_then_return_mock another_keynote
    expect(another_keynote).to receive(:open).with(file)
    expect(another_keynote).to receive(:select_all_slides)
    expect(another_keynote).to receive(:copy)
    expect(mock_keynote).to receive(:paste)
    expect(another_keynote).to receive(:close)
    expect(mock_keynote).to receive(:save)
  end

  def should_shutdown
    expect(mock_keynote).to receive(:close)
    expect(mock_keynote).to receive(:quit)
  end

  let(:mock_keynote) { double("First keynote")}

  it "Should exit if keynote windows are already open" do
    should_get_new_keynote_then_return_mock
    should_get_started
      .with("All Keynote windows must be closed before running this flow")
      .and_raise(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
    
    expect {
      CommonFlows.keynote_combine_files("result.key", "one_file.key")
    }.to raise_error(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
  end
  
  it "Should be able to combine just one single file" do
    should_get_new_keynote_then_return_mock
    should_get_started
    should_create_output_file_from_input("one_file.key", "result.key")
    should_shutdown
    CommonFlows.keynote_combine_files("result.key", "one_file.key")
  end
  
  it "Should be able to combine multiple files in one result" do
    should_get_new_keynote_then_return_mock
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
    expect(Dir).to receive(:new).with(".").and_return(files_in_dir)
    expect(CommonFlows).to receive(:keynote_combine_files).with("results.key", files_matching.sort)
    CommonFlows.keynote_combine_files_from_directory_sorted("results.key")    
  end

  it "Should be able to combine multiple files from one directory sorted with pattern" do
    files_in_dir = [".", "..", "05_file.key", "02key.wrong", "another", "01hey.key", "last"]
    files_in_dir_to_be_used = ["dirname/01hey.key", "dirname/05_file.key"]
    mocked_dir = double("Directory with keynote files")
    expect(Dir).to receive(:new).with("dirname").and_return(mocked_dir)
    expect(mocked_dir).to receive(:entries).and_return(files_in_dir)
    expect(CommonFlows).to receive(:keynote_combine_files).with("results.key", files_in_dir_to_be_used)
    CommonFlows.keynote_combine_files_from_directory_sorted("results.key", "dirname", /^\d+.*\.key$/)    
  end

  it "Should be able to open and close keynote files" do
    expect(Osaka::Keynote).to receive(:new).exactly(3).times.and_return(mock_keynote)
    should_get_started
    expect(mock_keynote).to receive(:open).with("file1.key")
    expect(mock_keynote).to receive(:close)
    expect(mock_keynote).to receive(:open).with("file2.key")
    expect(mock_keynote).to receive(:close)
    expect(mock_keynote).to receive(:quit)
    CommonFlows.keynote_yield_for_each_file(["file1.key", "file2.key"]) { |k| k.instance_of? Osaka::Keynote }
  end

  it "Should be able to combine a list of files fron a specified directory" do
    expect(File).to receive(:exist?).exactly(2).times.and_return(false)
    expect(STDOUT).to receive(:puts).exactly(1).times.with("These files do not exist: \ndir/file1.key\ndir/file2.key")
    CommonFlows.keynote_combine_files_from_list("results_file", "dir", ["file1.key", "file2.key"])
  end

  it "Should be complain when files in list do not exist" do
    expect(File).to receive(:exist?).exactly(2).times.and_return(true)
    expect(CommonFlows).to receive(:keynote_combine_files).with("results_file", ["dir/file1.key", "dir/file2.key"])
    CommonFlows.keynote_combine_files_from_list("results_file", "dir", ["file1.key", "file2.key"])
  end

  
end
