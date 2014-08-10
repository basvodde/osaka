
require "osaka"

describe "Common flows in keynote" do
  
  def should_shutdown
    expect(mock_keynote).to receive(:save)
    expect(mock_keynote).to receive(:close)
    expect(mock_keynote).to receive(:quit)
  end

  let(:mock_keynote) { double("First keynote")}

  it "Should exit if keynote windows are already open" do
    expect(Osaka::Keynote).to receive(:new).and_return(mock_keynote)
    expect(mock_keynote).to receive(:activate)
    expect(mock_keynote).to receive(:raise_error_on_open_standard_windows)
      .with("All Keynote windows must be closed before running this flow")
      .and_raise(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
    
    expect {
      CommonFlows.keynote_combine_files("result.key", "one_file.key")
    }.to raise_error(Osaka::ApplicationWindowsMustBeClosed, "All Keynote windows must be closed before running this flow")
  end
  
  it "Should be able to combine just one single file" do
    expect(Osaka::Keynote).to receive(:new).and_return(mock_keynote)
    expect(mock_keynote).to receive(:activate)
    expect(mock_keynote).to receive(:raise_error_on_open_standard_windows)
    expect(mock_keynote).to receive(:light_table_view)
    expect(mock_keynote).to receive(:open).with("one_file.key")
    expect(mock_keynote).to receive(:save_as).with("result.key")
    should_shutdown
    CommonFlows.keynote_combine_files("result.key", "one_file.key")
  end
  
  it "Should be able to combine multiple files in one result" do
    mock2_keynote = double("Second keynote")
    mock3_keynote = double("Third keynote")
    expect(Osaka::Keynote).to receive(:new).and_return(mock_keynote, mock2_keynote, mock3_keynote)  
    expect(mock_keynote).to receive(:activate)
    expect(mock_keynote).to receive(:raise_error_on_open_standard_windows)
    expect(mock_keynote).to receive(:open).with("one_file.key")
    expect(mock_keynote).to receive(:light_table_view)
    expect(mock_keynote).to receive(:save_as).with("result.key")
    expect(mock_keynote).to receive(:select_all_slides).exactly(2).times
    expect(mock_keynote).to receive(:paste).exactly(2).times
    
    expect(mock2_keynote).to receive(:open).with("two_file.key")
    expect(mock2_keynote).to receive(:select_all_slides)
    expect(mock2_keynote).to receive(:copy)
    expect(mock2_keynote).to receive(:close)
    
    expect(mock3_keynote).to receive(:open).with("three_file.key")
    expect(mock3_keynote).to receive(:select_all_slides)
    expect(mock3_keynote).to receive(:copy)
    expect(mock3_keynote).to receive(:close)
    
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
  
end
