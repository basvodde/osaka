require 'osaka'

describe "Integration tests for Preview" do
  
  before(:each) do
    @assets_directory =  File.join(File.dirname(__FILE__), "assets")
  end
        
  it "Should be able to open a file and check if there is a certain text" do
    preview = Osaka::Preview.new
    preview.open(File.join(@assets_directory, "document.pdf"))
    preview.pdf_content.should include("Jamaica")
    preview.close
    preview.quit    
  end
end