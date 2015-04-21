
require 'tmpdir'
require 'osaka'

describe "Integration of mail merge flow with Pages and Numbers", :integration => true do


  before (:each) do
    @tempdir = Dir.mktmpdir
    @pages_template_filename = File.join(@tempdir, "document.pages")
    @pdf_output_file = File.join(@tempdir, "output.pdf")
  end

  after (:each) do
    FileUtils.remove_entry_secure @tempdir
  end

  it "Should be able to open a new document" do

    Osaka::Pages.create_document(@pages_template_filename) { |doc|
      doc.type("Hello World! This is pages. We're going to mail merge!\r\r")
    }
  end
end
