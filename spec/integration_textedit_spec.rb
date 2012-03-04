
require 'osaka'

describe "Integration test using TextEdit" do

  subject { Osaka::TextEdit.new }

  before (:each) do
    subject.activate
  end
  
  after (:each) do
    subject.quit(:dont_save)
  end
  
  it "can type in the next window" do    
    subject.type("Hello World")
    subject.text.should == "Hello World"
  end

end