require 'tmpdir'
require 'osaka'

describe "Integration of mail merge flow with Pages and Numbers" do


  before (:each) do
    @tempdir = Dir.mktmpdir
    @numbers_filename = File.join(@tempdir, "mail_merge_test.numbers")
  end
  
  after (:each) do
    FileUtils.remove_entry_secure @tempdir
  end
  
  it "Should mail merge the assets and generate a PDF" do
    
    Osaka::Numbers.create_document (@numbers_filename) { |doc|
      doc.fill_cell(1, 1, "Data")
      doc.fill_cell(1, 2, "Hello World")
      doc.fill_cell(1, 3, "of Data")
      doc.fill_cell(1, 4, "in Numbers")
    }
    
    assets_directory =  File.join(File.dirname(__FILE__), "assets")
    pages_template = File.join(assets_directory, "mail_merge_template.pages")
    pdf_output_file = File.join(@tempdir, "output.pdf")
    CommonFlows::number_and_pages_mail_merge(@numbers_filename, pages_template, pdf_output_file)
    File.exists?(pdf_output_file).should == true
  end
end
