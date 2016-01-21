# encoding: utf-8
require 'osaka'

describe "Preview application for reading PDFs" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Preview.new }
  let(:control) { subject.control = double("RemoteControl", :mac_version => :mountain_lion)}

  it "Can get the text context of a PDF document (pre el capitain)" do
    expect_mac_version_before(:el_capitain).and_return(true)
    expect_get!("value", at.static_text(1).scroll_area(1).splitter_group(1)).and_return("Blah")
    expect(subject.pdf_content).to eq "Blah"
  end

  it "Can get the text context of a PDF document (post el capitain)" do
    expect_mac_version_before(:el_capitain).and_return(false)
    expect_get!("value", at.static_text(1).group(1).scroll_area(1).splitter_group(1)).and_return("Blah")
    expect(subject.pdf_content).to eq "Blah"
  end

  it "Can open a PDF file via the menu instead of the AppleScript 'open' as that one is buggy" do
    expect_click_menu_bar(at.menu_item("Open…"), "File")
    expect_wait_until_exists(at.window("Open"))
    expect(subject).to receive(:do_and_wait_for_new_window).and_yield.and_return("window name")
    expect(subject).to receive(:select_file_from_open_dialog).with("dir/filename", at.window("Open"))
    expect_set_current_window("window name")

    subject.open("dir/filename")
  end

end
