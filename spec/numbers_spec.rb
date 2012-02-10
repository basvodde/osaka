
require 'osaka'

describe "Osaka::Numbers" do

  subject { Osaka::Numbers.new }
  
  before (:each) do
    subject.wrapper = double("Osaka::Number").as_null_object
  end
  
  it "Should be able to fill in data in cells" do
    subject.wrapper.should_receive(:tell).with('tell document 1; tell sheet 1; tell table 1; set value of cell 1 of row 2 to "30"; end tell; end tell; end tell')
    subject.fill_cell(1, 2, "30")
  end
  
end