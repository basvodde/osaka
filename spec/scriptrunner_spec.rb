require 'osaka'

describe "Osaka::ScriptRunner" do

  subject { Osaka::ScriptRunner }

  it "Should be able to run single-line text as osascript" do
    subject.should_receive(:do_system).with('osascript -e "random number"').and_return("")
    subject.execute("random number").should == ""
  end
  
  it "Should escape quotes when passing text" do
    subject.should_receive(:do_system).with('osascript -e "say \\"hello\\""').and_return("")
    subject.execute('say "hello"')
  end
  
  it "Should be able to run on debug printing" do
    subject.should_receive(:do_system).and_return("Blah blah blah")
    subject.should_receive(:puts).with('Executing: osascript -e "random number"')
    subject.should_receive(:puts).with('Output was: Blah blah blah')
    Osaka::ScriptRunner::enable_debug_prints
    subject.execute("random number")
    Osaka::ScriptRunner::disable_debug_prints
  end
  
  it "Should not print any debugging information by default " do
    subject.should_receive(:do_system).and_return("")
    subject.should_not_receive(:puts)
    subject.execute("random number")
  end
  
  it "Should be able to define multi-line statements using ; as a separator" do
    subject.should_receive(:do_system).with('osascript -e "tell application \\"Calculator\\"" -e "activate" -e "end tell"').and_return("")
    subject.execute('tell application "Calculator"; activate; end tell')
  end
  
  it "Should raise an exception witha proper error message when the applescript fails" do
    subject.should_receive(:do_system).and_raise(Osaka::SystemCommandFailed)
    lambda {subject.execute("Fuck off!")}.should raise_error(Osaka::ScriptRunnerError, "Error received while executing: Fuck off!")
  end
  
  it "Should be able to execute an file containing applescript" do
    subject.should_receive(:do_system).with('osascript script.scpt').and_return(true)
    subject.execute_file("script.scpt")
  end
  
  it "Should be able to pass parameters to an applescript" do
    subject.should_receive(:do_system).with('osascript script.scpt a b c').and_return(true)
    subject.execute_file("script.scpt", "a b c")    
  end
end
