
require 'osaka'

describe "Osaka::Keynote" do

  subject { Osaka::Keynote.new }
  
  before (:each) do
    subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
  end
  
  it "Should create the correct keynote print dialog" do
    subject.create_print_dialog("window").class.should == Osaka::KeynotePrintDialog
  end
  
end
