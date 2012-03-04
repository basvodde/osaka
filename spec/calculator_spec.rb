
require 'osaka'

describe "Mac GUI Calculator" do

  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::Calculator.new }

  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
  end
  
  it "Should be able to click a button on the calculator" do
    expect_click!('button "1" of group 2 of window "Calculator"')
    subject.click("1")
  end
  
  it "Should be able to use keystroke on the calculator" do
    expect_keystroke("1")
    subject.key("1")
  end
  
  it "Should be able to activate the calculator" do
    @wrapper.should_receive(:activate)
    subject.activate
  end
  
  it "Should be able to quit the calculator" do
    @wrapper.should_receive(:quit)
    subject.quit
  end
  
  it "Should be able to get the value from the screen" do
    @wrapper.should_receive(:get!).with("value", 'static text 1 of group 1 of window "Calculator"').and_return("0")
    subject.result.should == "0"
  end
  
end