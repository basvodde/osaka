
require 'osaka'

describe "Osaka::Keynote" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Keynote.new }
  let(:control) {subject.control = double("RemoteControl")}
  
  it "Should create the correct keynote print dialog" do
    expect(subject.create_print_dialog("window")).to be_instance_of Osaka::KeynotePrintDialog
  end
  
  it "Should be possible to select all the slides by switching to light table view" do
    expect(subject).to receive(:light_table_view)
    expect(subject).to receive(:select_all)
    subject.select_all_slides
  end
  
  it "Should click light table view when the dialog is there" do
    expect(subject.control).to receive(:exists?).and_return(true)
    expect(subject.control).to receive(:click)
    expect(subject).to receive(:select_all)
    subject.select_all_slides
  end
  
  it "Should not click the dialog when it is not there" do
    expect(subject.control).to receive(:exists?).and_return(false)
    expect(subject.control).to receive(:click).exactly(0).times
    expect(subject).to receive(:select_all)
    subject.select_all_slides
  end
 
  it "Should ask for and click the light table view menu" do
    light_table_view_selection = at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1) 
    expect_exists?(light_table_view_selection).and_return(true)
    expect_click(light_table_view_selection)
    expect(subject).to receive(:select_all)
    subject.select_all_slides
  end

  it "Should use the command line open to make up for problem in keynote 6.2" do
    expect(File).to receive(:absolute_path).with("file.key").and_return("/path/file.key")
    expect(subject).to receive(:do_and_wait_for_new_window).and_yield.and_return("new_window")
    expect(subject.control).to receive(:run_command).with("open /path/file.key").and_return("something that is printed during debug")
    expect(subject.control).to receive(:wait_until_exists)
    expect(subject.control).to receive(:set_current_window).with("new_window")
    subject.open("file.key")
  end

end
