
require 'osaka'

describe "Osaka::Numbers" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Numbers.new }  
  let(:control) { subject.control = mock("RemoteControl").as_null_object}
  
  it "Should be able to fill in data in cells" do
    expect_tell('tell document 1; tell sheet 1; tell table 1; set value of cell 1 of row 2 to "30"; end tell; end tell; end tell')
    subject.fill_cell(1, 2, "30")
  end
  
  it "Should be able to select blank from the template choser" do
    expect_set_current_window("Template Choser")
    subject.should_receive(:do_and_wait_for_new_window).and_return("Template Choser")
    expect_set_current_window("Untitled")
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("Untitled")
    expect_keystroke(:return)
    subject.new_document 
  end
  
  it "Should be able to use a class method for creating documents quickly" do
      Osaka::Numbers.should_receive(:new).any_number_of_times.and_return(mock("App"))
      subject.should_receive(:create_document)

      Osaka::Numbers.create_document("filename") { |doc|
      }    
  end
    
end