require 'tmpdir'
require 'osaka'

describe "Integration of mail merge flow with Pages and Numbers" do
  
  it "Should mail merge the assets and generate a PDF" do
    
    assets_directory =  File.join(File.dirname(__FILE__), "assets")
    numbers_data = File.join(assets_directory, "mail_merge_data.numbers")
    pages_template = File.join(assets_directory, "mail_merge_template.pages")
    Dir.mktmpdir { |dir|
      pdf_output_file = File.join(dir, "output.pdf")
      CommonFlows::number_and_pages_mail_merge(numbers_data, pages_template, pdf_output_file)
      File.exists?(pdf_output_file).should == true
    }
  end
end
