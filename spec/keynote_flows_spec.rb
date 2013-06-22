
require "osaka"

describe "Common flows in keynote" do

  let(:mock_keynote) { mock("First keynote")}

  it "Should be able to combine just one single file" do
    Osaka::Keynote.should_receive(:new).and_return(mock_keynote)
    mock_keynote.should_receive(:light_table_view)
    mock_keynote.should_receive(:open).with("one_file.key")
    mock_keynote.should_receive(:save_as).with("result.key")
    mock_keynote.should_receive(:save)
    mock_keynote.should_receive(:quit)
    CommonFlows.keynote_combine_files("result.key", "one_file.key")
  end
  
  it "Should be able to combine multiple files in one result" do
    mock2_keynote = mock("Second keynote")
    mock3_keynote = mock("Third keynote")
    Osaka::Keynote.should_receive(:new).and_return(mock_keynote, mock2_keynote, mock3_keynote)  
    mock_keynote.should_receive(:open).with("one_file.key")
    mock_keynote.should_receive(:light_table_view)
    mock_keynote.should_receive(:save_as).with("result.key")
    mock_keynote.should_receive(:select_all_slides).exactly(2).times
    mock_keynote.should_receive(:paste).exactly(2).times
    mock_keynote.should_receive(:save)
    

    mock2_keynote.should_receive(:open).with("two_file.key")
    mock2_keynote.should_receive(:select_all_slides)
    mock2_keynote.should_receive(:copy)
    mock2_keynote.should_receive(:close)
    
    mock3_keynote.should_receive(:open).with("three_file.key")
    mock3_keynote.should_receive(:select_all_slides)
    mock3_keynote.should_receive(:copy)
    mock3_keynote.should_receive(:close)
    
    mock_keynote.should_receive(:quit)
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
    mocked_dir = mock("Directory with keynote files")
    Dir.should_receive(:new).with("dirname").and_return(mocked_dir)
    mocked_dir.should_receive(:entries).and_return(files_in_dir)
    CommonFlows.should_receive(:keynote_combine_files).with("results.key", files_in_dir_to_be_used)
    CommonFlows.keynote_combine_files_from_directory_sorted("results.key", "dirname", /^\d+.*\.key$/)    
  end
  
end