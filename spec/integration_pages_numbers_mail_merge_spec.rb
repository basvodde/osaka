require 'tmpdir'
require 'osaka'

describe "Integration of mail merge flow with Pages and Numbers", :integration => true do


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

    Osaka::Numbers.create_document(@numbers_filename) { |doc|
      doc.fill_cell(2, 1, "Data")
      doc.fill_cell(2, 2, "Hello World")
      doc.fill_cell(2, 3, "of Data")
      doc.fill_cell(2, 4, "in Numbers")
    }

    Osaka::Pages.create_document(@pages_template_filename) { |doc|
      doc.set_mail_merge_document(@numbers_filename)
      doc.type("Hello World! This is pages. We're going to mail merge!\r\r")
      doc.mail_merge_field("Data");
    }

    CommonFlows::number_and_pages_mail_merge(@numbers_filename, @pages_template_filename, @pdf_output_file)
    expect(File.exists?(@pdf_output_file)).to eq true

    preview = Osaka::Preview.new
    preview.open(@pdf_output_file)
    expect(preview.pdf_content).to include("Hello World")
    preview.close
    preview.quit
  end
end
