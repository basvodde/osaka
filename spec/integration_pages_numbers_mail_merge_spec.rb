require 'tmpdir'
require 'osaka'

describe "Integration of mail merge flow with Pages and Numbers" do


  before (:each) do
    @tempdir = Dir.mktmpdir
    @numbers_filename = File.join(@tempdir, "mail_merge_test.numbers")
    @pages_template_filename = File.join(@tempdir, "mail_merge_template.pages")
    @pdf_output_file = File.join(@tempdir, "output.pdf")
  end
  
  after (:each) do
    FileUtils.remove_entry_secure @tempdir
  end
  
  it "Should mail merge the assets and generate a PDF" do

    Osaka::Numbers.create_document (@numbers_filename) { |doc|
      doc.fill_cell(2, 1, "Data")
      doc.fill_cell(2, 2, "Hello World")
      doc.fill_cell(2, 3, "of Data")
      doc.fill_cell(2, 4, "in Numbers")
    }
    
    pages = Osaka::Pages.new
    pages.new_document
    pages.set_mail_merge_document(@numbers_filename)
    
    pages.type("Hello World! This is pages. We're going to mail merge!\r\r")    
    pages.mail_merge_field("Data");
    pages.save_as(@pages_template_filename)
    pages.close
    
    CommonFlows::number_and_pages_mail_merge(@numbers_filename, @pages_template_filename, @pdf_output_file)
    File.exists?(@pdf_output_file).should == true
  end
end
