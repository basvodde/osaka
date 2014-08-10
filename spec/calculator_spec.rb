
require 'osaka'

describe "Mac GUI Calculator" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Calculator.new }
  let(:control) { subject.control = double("RemoteControl", :mac_version => :mountain_lion)}
    
  it "Should be setting the window when starting the Calculator" do
        
    expect_activate
    expect_current_window_name.and_return("")
    expect(subject).to receive(:wait_for_new_window).with([])
    expect_window_list.and_return(["Calculator"])
    expect_set_current_window("Calculator")
    subject.activate
  end
    
  it "Should be able to click a button on the calculator" do
    expect_click!(at.button("1").group(2))
    subject.click("1")
  end
  
  it "Should be able to use keystroke on the calculator" do
    expect_keystroke("1")
    subject.key("1")
  end
  
  it "Should be able to quit the calculator" do
    expect_running?.and_return(true)
    expect_quit
    subject.quit
  end
  
  it "Should be able to get the value from the screen" do
    expect_wait_until_exists!(at.static_text(1).group(1))
    expect_get!("value", at.static_text(1).group(1)).and_return("0")
    expect(subject.result).to eq "0"
  end
  
end
