
require 'osaka'

describe "TextEdit" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::TextEdit.new }

  let(:control) { subject.control = double("RemoteControl") }

  it "Should be able to type some text" do
    expect_keystroke('Hello World')
    subject.type("Hello World")
  end
  
  it "Should be able to get the text from the document" do
    expect_get!("value", 'text area 1 of scroll area 1').and_return("Hello")
    expect(subject.text).to eq "Hello"
  end

end
