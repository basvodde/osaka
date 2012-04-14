
require 'osaka'

describe "TextEdit" do

  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::TextEdit.new }

  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
  end
  
  it "should set the window on activation" do
    @wrapper.should_receive(:activate)
    @wrapper.should_receive(:window).and_return(nil)
    subject.should_receive(:wait_for_new_window).with([])
    @wrapper.should_receive(:window_list).and_return(["Untitled"])
    @wrapper.should_receive(:window=).with("Untitled")
    subject.activate
  end
  
  it "shouldn't set the window on activation when it is already set" do
    @wrapper.should_receive(:activate)
    @wrapper.should_receive(:window).and_return("Untitled")
    subject.activate    
  end
  
  it "Should be able to type some text" do
    expect_keystroke('Hello World')
    subject.type("Hello World")
  end
  
  it "Should be able to get the text from the document" do
    subject.wrapper.should_receive(:get!).with("value", 'text area 1 of scroll area 1').and_return("Hello")
    subject.text.should == "Hello"
  end

end