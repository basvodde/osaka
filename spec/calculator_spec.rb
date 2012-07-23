
require 'osaka'

describe "Mac GUI Calculator" do

  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::Calculator.new }

  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
  end
  
  it "Should be setting the window when starting the Calculator" do
    
    # TODO: Fix this duplication between this and TextEdit.
    
    @wrapper.should_receive(:activate)
    @wrapper.should_receive(:current_window_name).and_return("")
    subject.should_receive(:wait_for_new_window).with([])
    @wrapper.should_receive(:window_list).and_return(["Calculator"])
    @wrapper.should_receive(:set_current_window).with("Calculator")
    subject.activate
  end
    
  it "Should be able to click a button on the calculator" do
    expect_click!(at.button("1").group(2))
    subject.click("1")
  end
  
  it "Should be able to use keystroke on the calculator" do
    expect_keystroke("1")
    subject.key("1")
  end
  
  it "Should be able to quit the calculator" do
    @wrapper.should_receive(:running?).and_return(true)
    @wrapper.should_receive(:quit)
    subject.quit
  end
  
  it "Should be able to get the value from the screen" do
    @wrapper.should_receive(:get!).with("value", at.static_text(1).group(1)).and_return("0")
    subject.result.should == "0"
  end
  
end