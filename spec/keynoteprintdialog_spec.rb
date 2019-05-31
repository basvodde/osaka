# encoding: utf-8
require 'osaka'

describe "Osaka::KeynotePrintDialog" do

  include(*Osaka::OsakaExpectations)
  subject { Osaka::KeynotePrintDialog.new("App", at.window("Print")) }
    
  let(:control) { subject.control = double("RemoteControl", :name => "App") }
  margins_checkbox = at.checkbox("Use page margins").group(3)
  backgrounds_checkbox = at.checkbox("Print slide backgrounds")
  animations_checkbox = at.checkbox("Print each stage of builds")

  def expect_check_box_should_be_set(element)
    expect(control).to receive(:set_checkbox).with(element, true)
  end

  def expect_check_box_should_be_cleared(element)
    expect(control).to receive(:set_checkbox).with(element, false)
  end

  it "Should be able to set margins, backgrounds, animations" do
    expect_check_box_should_be_set(margins_checkbox)
    expect_check_box_should_be_set(backgrounds_checkbox)
    expect_check_box_should_be_set(animations_checkbox)

    subject.margins(true)
    subject.backgrounds(true)
    subject.animations(true)
  end

  it "Should be able to clear margins, backgrounds, animations" do
    expect_check_box_should_be_cleared(margins_checkbox)
    expect_check_box_should_be_cleared(backgrounds_checkbox)
    expect_check_box_should_be_cleared(animations_checkbox)

    subject.margins(false)
    subject.backgrounds(false)
    subject.animations(false)
  end

end
