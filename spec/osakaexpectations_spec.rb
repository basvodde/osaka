
require 'osaka'

describe "Osakas Ruby expectations" do

  include(*Osaka::OsakaExpectations)

  subject { double("RemoteControl") }
  let(:control) { subject }
  
  it "Wait until exists can be called without a code block" do
    expect_wait_until_exists!(at.window(1))
    subject.wait_until_exists!(at.window(1))
  end

  it "Wait until exists can be called with a code block" do
    code_block_been_called = false
    expect_wait_until_exists!(at.window(1)).and_yield
    
    subject.wait_until_exists!(at.window(1)) {
      code_block_been_called = true
    }
    code_block_been_called.should be true
  end

end