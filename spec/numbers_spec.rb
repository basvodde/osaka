
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
  
  it "Should be able to easily create a document, put something, save it, and close it again" do
    
    Osaka::Numbers.should_receive(:new).any_number_of_times.and_return(mock("Numbers"))
    subject.should_receive(:new_document)
    subject.should_receive(:method_call_from_code_block)
    subject.should_receive(:save_as).with("filename")
    subject.should_receive(:close)

    Osaka::Numbers.create_document("filename") { |doc|
      doc.method_call_from_code_block
    }
    
  end
  
  
  
end