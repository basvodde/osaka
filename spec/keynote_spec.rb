
require 'osaka'

describe "Osaka::Keynote" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Keynote.new }
  let(:control) {subject.control = mock("RemoteControl").as_null_object}
  
  it "Should create the correct keynote print dialog" do
    subject.create_print_dialog("window").should be_instance_of Osaka::KeynotePrintDialog
  end
  
  it "Should be possible to select all the slides by switching to light table view" do
    light_table_view_selection = at.menu_item("Light Table").menu(1).menu_bar_item("View").menu_bar(1) 
    expect_exists?(light_table_view_selection).and_return(true)
    expect_click(light_table_view_selection)
    subject.should_receive(:light_table_view)
    subject.should_receive(:select_all)
    subject.select_all_slides
  end
  
end
