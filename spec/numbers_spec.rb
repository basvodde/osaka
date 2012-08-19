
require 'osaka'

describe "Osaka::Numbers" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Numbers.new }  
  let(:control) { subject.control = mock("RemoteControl").as_null_object}
  
  it "Should be able to fill in data in cells" do
    expect_tell('tell document 1; tell sheet 1; tell table 1; set value of cell 1 of row 2 to "30"; end tell; end tell; end tell')
    subject.fill_cell(1, 2, "30")
  end
  
end