
require 'osaka'

describe "Integration test using TextEdit", :integration => true do

  subject { Osaka::TextEdit.new }

  before (:each) do
    if subject.running?
        subject.quit(:dont_save)
      end
  end
  
  after (:each) do
    subject.quit(:dont_save)
  end
  
  it "can type in the window" do
    subject.new_document
    subject.type("Hello World")
    subject.text.should == "Hello World"
    subject.close(:dont_save)
  end
  
  it "can type in two windows using two instances" do
    editor1 = subject
    editor2 = Osaka::TextEdit.new
        
    editor1.new_document
    editor2.new_document
    
    editor1.type("Typing in window 1")
    editor2.type("Typing in window 2")
        
    editor1.text.should == "Typing in window 1"
    editor2.text.should == "Typing in window 2"
    
    editor1.close(:dont_save)
    editor2.close(:dont_save)
  end

end
