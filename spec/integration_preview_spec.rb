require 'osaka'

describe "Integration tests for Preview", :integration => true do

  before(:each) do
    @assets_directory =  File.join(File.dirname(__FILE__), "assets")
  end

  it "Should be able to open a file and check if there is a certain text" do
    Osaka::ScriptRunner::enable_debug_prints
    preview = Osaka::Preview.new
    preview.open(File.join(@assets_directory, "document.pdf"))
    expect(preview.pdf_content).to include("Hungary")
    preview.close
    preview.quit
  end
end
