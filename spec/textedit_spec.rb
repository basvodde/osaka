
require 'osaka'

describe "TextEdit" do

  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::TextEdit.new }

  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
  end
  
  it "Should be able to type some text" do
    expect_keystroke!('Hello World')
    subject.type("Hello World")
  end
  
  it "Should be able to get the text from the document" do
    subject.wrapper.should_receive(:get!).with("value", 'text area 1 of scroll area 1 of window "Untitled"').and_return("Hello")
    subject.text.should == "Hello"
  end

end