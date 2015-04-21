require 'tmpdir'
require 'osaka'

describe "Integration tests for Numbers" do

  it "Should be able to fill in large index cells", :integration => true do

    Dir.mktmpdir { |dir|

      Osaka::Numbers.create_document(File.join(dir, "temp.numbers")) { |doc|
        doc.fill_cell(12, 1, "Data")
      }
    }

  end

end
