# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalOpenDialog" do
  
  include(*Osaka::OsakaExpectations)
  subject { Osaka::TypicalOpenDialog.new("Application", at.window(1))}
  let(:control) { subject.control = mock("RemoteControl", :base_location => at.window(1)) }
  
  
  it "Should be able to select a file" do
    subject.should_receive(:amount_of_files_in_list)
    subject.should_receive(:filename_at).with(1).and_return("filename")
    subject.should_receive(:select_filename_at).with(1)
    subject.should_receive(:open)
    
    subject.select_file("filename")
  end

  it "Should be able to get the name of a file from a row" do
    expect_get!("value", subject.text_field_location_from_row(1)).and_return("filename")
    subject.filename_at(1).should == "filename"
  end

  it "Should be able to get the amount of files in the current file list" do
    expect_get!("rows", subject.file_list_location).and_return("row 1 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages")
    subject.amount_of_files_in_list.should == 1
  end
  
  it "Should be able to get the amount of files in the current file list with 2 files." do
    expect_get!("rows", subject.file_list_location).and_return("row 1 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages, row 2 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages")
    subject.amount_of_files_in_list.should == 2    
  end
  
  it "Should be able to get the amount of files in the current file list when there are no files..." do
    expect_get!("rows", subject.file_list_location).and_return("")
    subject.amount_of_files_in_list.should == 0
  end  
    
  it "Should be able to convert a row into a location" do
    subject.text_field_location_from_row(1).should == at.text_field(1).ui_element(1).row(1) + subject.file_list_location
  end
  
  it "Should be able to get the location of the list" do
    subject.file_list_location.should == at.outline(1).scroll_area(2).splitter_group(1).group(1)
  end
end
