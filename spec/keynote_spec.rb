
require 'osaka'

describe "Osaka::Keynote" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Keynote.new }
  let(:wrapper) {subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object}
  
  it "Should create the correct keynote print dialog" do
    subject.create_print_dialog("window").should be_instance_of Osaka::KeynotePrintDialog
  end
  
  it "Should be possible to select all the slides in the default location" do
    slides_button_location = at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1)    
    expect_exists(slides_button_location).and_return(true)
    expect_click(slides_button_location)
    subject.should_receive(:select_all)
    subject.select_all_slides
  end

  it "Should be possible to select all the slides in the alternative location" do
    slides_button_location = at.button("Slides").group(1).outline(1).scroll_area(2).splitter_group(1).splitter_group(1)    
    alternative_slides_button_location = at.button("Slides").group(1).outline(1).scroll_area(1).splitter_group(1).splitter_group(1)
    expect_exists(slides_button_location).and_return(false)
    expect_click(alternative_slides_button_location)
    subject.should_receive(:select_all)
    subject.select_all_slides
  end
  
  
end
