
require 'osaka'

describe "Integration test using the Calculator", :integration => true do

  subject { Osaka::Calculator.new }

  before (:each) do
    subject.activate
  end
  
  after (:each) do
    subject.quit
  end
  
  it "Should be able to get info from the calculator" do
    app_info = subject.get_info
  end
  
  it "Should be able to do calculations with mouse" do
    subject.click("1")
    subject.click("+")
    subject.click("1")
    subject.click("=")
    expect(subject.result).to eq "2"
  end
  
  it "Should be able to do calculations using keyboard" do
    subject.key("10")
    subject.key("*")
    subject.key("10")
    subject.key("+")
    expect(subject.result).to eq "100"    
  end
  
  it "Should do whole formulas using key" do
    subject.key("100+10*3+99+")
    expect(subject.result).to eq "229"        
  end
  
end
