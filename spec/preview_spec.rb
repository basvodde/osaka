
require 'osaka'

describe "Preview application for reading PDFs" do
  
  include(*Osaka::OsakaExpectations)

  subject { Osaka::Preview.new }
  let(:control) { subject.control = mock("RemoteControl", :mac_version => :mountain_lion)}

  it "Can get the text context of a PDF document" do

    expect_get!("value", at.static_text(1).scroll_area(1).splitter_group(1)).and_return("Blah")
    subject.pdf_content.should == "Blah"
  end
end