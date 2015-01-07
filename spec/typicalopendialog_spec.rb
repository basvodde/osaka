# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalOpenDialog" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::TypicalOpenDialog.new("Application", at.window(1))}
  let(:control) { subject.control ||= double("RemoteControl", :base_location => at.window(1), :mac_version => :mountain_lion) }

  it "Should be do nothing when the amount of files in the directory is 0" do
    expect(subject).to receive(:amount_of_files_in_list).and_return(0)
    subject.select_file("filename")
  end

  it "Should be able to select a file from Row 1" do
    expect(subject).to receive(:amount_of_files_in_list).and_return(1)
    expect(subject).to receive(:filename_at).with(1).and_return("filename")
    expect(subject).to receive(:select_file_by_row).with(1)
    expect(subject).to receive(:click_open)

    subject.select_file("filename")
  end

  it "Should be able to select a file from Row 3" do
    expect(subject).to receive(:amount_of_files_in_list).and_return(10)
    expect(subject).to receive(:filename_at).and_return("filename", "filename2", "filename3")
    expect(subject).to receive(:select_file_by_row).with(3)
    expect(subject).to receive(:click_open)

    subject.select_file("filename3")
  end

  it "Should be able to click open" do
    expect_click(at.button("Open"))
    subject.click_open
  end


  it "Should be able to get the name of a file from a row" do
    expect(subject).to receive(:field_location_from_row).and_return(at.window("Location"))
    expect_get!("value", at.window("Location")).and_return("filename")
    expect(subject.filename_at(1)).to eq "filename"
  end

  it "Should be able to select the filename (when that is possible)" do
    expect(subject).to receive(:greyed_out?).and_return(false)
    expect_set!("selected", at.row(1) + subject.file_list_location, true)
    subject.select_file_by_row(1)
  end

  it "Should throw an exception when the filename that we want to select is greyed out" do
    expect(subject).to receive(:greyed_out?).and_return(true)
    expect { subject.select_file_by_row(1)}.to raise_error(Osaka::OpenDialogCantSelectFile, "Tried to select a file, but it either doesn't exist or is greyed out")
  end

  it "Should be able to get the amount of files in the current file list" do
    expect_get!("rows", subject.file_list_location).and_return("row 1 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages")
    expect(subject.amount_of_files_in_list).to eq 1
  end

  it "Should be able to get the amount of files in the current file list with 2 files." do
    expect_get!("rows", subject.file_list_location).and_return("row 1 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages, row 2 of outline 1 of scroll area 2 of splitter group 1 of group 1 of window Open of application process Pages")
    expect(subject.amount_of_files_in_list).to eq 2
  end

  it "Should be able to get the amount of files in the current file list when there are no files..." do
    expect_get!("rows", subject.file_list_location).and_return("")
    expect(subject.amount_of_files_in_list).to eq 0
  end

  it "Should be able to convert a row into a location when it is a text field" do
    expect_exists?(subject.text_field_location_from_row(1)).and_return(true)
    expect(subject.field_location_from_row(1)).to eq subject.text_field_location_from_row(1)
  end

  it "Should be able to convert a row into a location when it is a static field." do
    expect_exists?(subject.text_field_location_from_row(1)).and_return(false)
    expect(subject.field_location_from_row(1)).to eq subject.static_field_location_from_row(1)
  end

  it "Should be able to get the location of the list" do
    simulate_mac_version(:mountain_lion)
    expect(subject.file_list_location).to eq at.outline(1).scroll_area(2).splitter_group(1).group(1)
  end

  it "Should be able to get the location of the list Yosemite" do
    simulate_mac_version(:yosemite)
    expect(subject.file_list_location).to eq at.outline(1).scroll_area(1).splitter_group(1).splitter_group(1).group(1)
  end
end
