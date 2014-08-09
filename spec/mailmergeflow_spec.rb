
require "osaka"

describe "Mail Merge to PDF common flow" do

  let(:mock_numbers) { double("Number")}
  let(:mock_pages) { double("Pages") }

  it "Should do a good mail merge with Pages and Keynote flow" do
    
    expect(Osaka::Numbers).to receive(:create_document).with("/template/numbers").and_yield(mock_numbers)
    
    Osaka::Pages.should_receive(:new).and_return(mock_pages)
    
    mock_pages.should_receive(:open).with("/template/pages")
    mock_pages.should_receive(:set_mail_merge_document).with("/template/numbers")
    mock_pages.should_receive(:mail_merge_to_pdf).with("/output/file.pdf")
    
    mock_pages.should_receive(:close).with(:dont_save)    
    mock_pages.should_receive(:quit).with(:dont_save)
    
    CommonFlows.number_and_pages_mail_merge("/template/numbers", "/template/pages", "/output/file.pdf") {}
  end
  
  it "Should yield for filling in the numbers fields" do
    mock_numbers.as_null_object
    mock_pages.as_null_object
    expect(Osaka::Numbers).to receive(:create_document).and_yield(mock_numbers)
    Osaka::Pages.should_receive(:new).and_return(mock_pages)

    retrieved_numbers = nil
    CommonFlows.number_and_pages_mail_merge("1", "2", "3") { |numbers|
      retrieved_numbers = numbers
    }    
    retrieved_numbers.should == mock_numbers
  end
  
end
