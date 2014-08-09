
require "osaka"

describe "Mail Merge to PDF common flow" do

  let(:mock_numbers) { double("Number")}
  let(:mock_pages) { double("Pages") }

  it "Should do a good mail merge with Pages and Keynote flow" do
    
    expect(Osaka::Numbers).to receive(:create_document).with("/template/numbers").and_yield(mock_numbers)
    
    expect(Osaka::Pages).to receive(:new).and_return(mock_pages)
    
    expect(mock_pages).to receive(:open).with("/template/pages")
    expect(mock_pages).to receive(:set_mail_merge_document).with("/template/numbers")
    expect(mock_pages).to receive(:mail_merge_to_pdf).with("/output/file.pdf")
    
    expect(mock_pages).to receive(:close).with(:dont_save)    
    expect(mock_pages).to receive(:quit).with(:dont_save)
    
    CommonFlows.number_and_pages_mail_merge("/template/numbers", "/template/pages", "/output/file.pdf") {}
  end
  
  it "Should yield for filling in the numbers fields" do
    mock_numbers.as_null_object
    mock_pages.as_null_object
    expect(Osaka::Numbers).to receive(:create_document).and_yield(mock_numbers)
    expect(Osaka::Pages).to receive(:new).and_return(mock_pages)

    retrieved_numbers = nil
    CommonFlows.number_and_pages_mail_merge("1", "2", "3") { |numbers|
      retrieved_numbers = numbers
    }    
    expect(retrieved_numbers).to eq mock_numbers
  end
  
end
