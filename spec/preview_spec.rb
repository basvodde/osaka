# encoding: utf-8
require 'osaka'

describe "Preview application for reading PDFs" do
  
  include(*Osaka::OsakaExpectations)

  subject { Osaka::Preview.new }
  let(:control) { subject.control = double("RemoteControl", :mac_version => :mountain_lion)}

  it "Can get the text context of a PDF document" do
    expect_get!("value", at.static_text(1).scroll_area(1).splitter_group(1)).and_return("Blah")
    subject.pdf_content.should == "Blah"
  end
  
  it "Can open a PDF file via the menu instead of the AppleScript 'open' as that one is buggy" do
    
    expect_click_menu_bar(at.menu_item("Open…"), "File")
    expect_wait_until_exists(at.window("Open"))
    subject.stub(:do_and_wait_for_new_window).and_yield.and_return("window name")    
    expect(subject).to receive(:select_file_from_open_dialog).with("dir/filename", at.window("Open"))
    expect_set_current_window("window name")

    subject.open("dir/filename")
  end
  
end
