# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalOpenDialog" do
  
  include(*Osaka::OsakaExpectations)
  subject { Osaka::TypicalOpenDialog.new("Application", at.window(1))}
  let(:control) { subject.control = double("RemoteControl", :base_location => at.window(1)) }
  
  
  it "Should be do nothing when the amount of files in the directory is 0" do
    subject.should_receive(:amount_of_files_in_list).and_return(0)
    subject.select_file("filename")
  end

  it "Should be able to select a file from Row 1" do
    subject.should_receive(:amount_of_files_in_list).and_return(1)
    subject.should_receive(:filename_at).with(1).and_return("filename")
    subject.should_receive(:select_file_by_row).with(1)
    subject.should_receive(:click_open)
    
    subject.select_file("filename")
  end

  it "Should be able to select a file from Row 3" do
    subject.should_receive(:amount_of_files_in_list).and_return(10)
    subject.should_receive(:filename_at).and_return("filename", "filename2", "filename3")
    subject.should_receive(:select_file_by_row).with(3)
    subject.should_receive(:click_open)
    
    subject.select_file("filename3")
  end
  
  it "Should be able to click open" do
    expect_click(at.button("Open"))
    subject.click_open
  end
  

  it "Should be able to get the name of a file from a row" do
    subject.should_receive(:field_location_from_row).and_return(at.window("Location"))
    expect_get!("value", at.window("Location")).and_return("filename")
    subject.filename_at(1).should == "filename"
  end
  
  it "Should be able to select the filename (when that is possible)" do
    subject.should_receive(:greyed_out?).and_return(false)
    expect_set!("selected", at.row(1) + subject.file_list_location, true)
    subject.select_file_by_row(1)
  end
  
  it "Should throw an exception when the filename that we want to select is greyed out" do
    subject.should_receive(:greyed_out?).and_return(true)
    expect { subject.select_file_by_row(1)}.to raise_error(Osaka::OpenDialogCantSelectFile, "Tried to select a file, but it either doesn't exist or is greyed out")
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
    
  it "Should be able to convert a row into a location when it is a text field" do
    expect_exists?(subject.text_field_location_from_row(1)).and_return(true)
    subject.field_location_from_row(1).should == subject.text_field_location_from_row(1)
  end
  
  it "Should be able to convert a row into a location when it is a static field." do
    expect_exists?(subject.text_field_location_from_row(1)).and_return(false)
    subject.field_location_from_row(1).should == subject.static_field_location_from_row(1)    
  end
  
  it "Should be able to get the location of the list" do
    subject.file_list_location.should == at.outline(1).scroll_area(2).splitter_group(1).group(1)
  end
end
