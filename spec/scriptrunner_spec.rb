require 'osaka'

describe "Osaka::ScriptRunner" do

  subject { Osaka::ScriptRunner }

  it "Should be able to run single-line text as osascript" do
    expect(Osaka::CommandRunner).to receive(:run).with('osascript -e "random number"').and_return("")
    expect(subject.execute("random number")).to eq ""
  end
  
  it "Should escape quotes when passing text" do
    expect(Osaka::CommandRunner).to receive(:run).with('osascript -e "say \\"hello\\""').and_return("")
    subject.execute('say "hello"')
  end
  
  it "Should be able to run on debug printing" do
    expect(Osaka::CommandRunner).to receive(:run).and_return("Blah blah blah")
    expect(subject).to receive(:puts).with('Executing: osascript -e "random number"')
    expect(subject).to receive(:puts).with('Output was: Blah blah blah')
    Osaka::ScriptRunner::enable_debug_prints
    subject.execute("random number")
    Osaka::ScriptRunner::disable_debug_prints
  end

  it "Should be able to run on debug printing with HTML tags" do
    expect(Osaka::CommandRunner).to receive(:run).and_return("Blah blah blah")
    expect(subject).to receive(:puts).with('random number<br>')
    expect(subject).to receive(:puts).with('Output: <b>Blah blah blah</b><br>')
    Osaka::ScriptRunner::enable_debug_prints(:short_html)
    subject.execute("random number")
    Osaka::ScriptRunner::disable_debug_prints
  end
  
  it "Should be able to generate a script of the run for later debugging purposes" do
    expect(Osaka::CommandRunner).to receive(:run).and_return("Blah blah blah")
    file = double("Mocked output file")
    expect(File).to receive(:open).with("output_script", File::WRONLY|File::APPEND|File::CREAT, 0755).and_yield(file)
    expect(file).to receive(:puts).with("osascript -e \"random number\"")
    Osaka::ScriptRunner.enable_debug_prints(:script, "output_script")
    subject.execute("random number")
    Osaka::ScriptRunner::disable_debug_prints
  end
  
  it "Should explain how to turn on the access for assistive devices when it is disabled... and exit" do
    expect(Osaka::CommandRunner).to receive(:run).and_raise(Osaka::SystemCommandFailed.new ("execution error: System Events got an error: Access for assistive devices is disabled. (-25211)"))
    expect(subject).to receive(:puts).with(/system preferences/)
    expect(subject).to receive(:exit)
    subject.execute("anything")
  end
    
  it "Should not print any debugging information by default " do
    expect(Osaka::CommandRunner).to receive(:run).and_return("")
    expect(subject).not_to receive :puts
    subject.execute("random number")
  end
  
  it "Should be able to define multi-line statements using ; as a separator" do
    expect(Osaka::CommandRunner).to receive(:run).with('osascript -e "tell application \\"Calculator\\"" -e "activate" -e "end tell"').and_return("")
    subject.execute('tell application "Calculator"; activate; end tell')
  end
  
  it "Should raise an exception witha proper error message when the applescript fails" do
    expect(Osaka::CommandRunner).to receive(:run).and_raise(Osaka::SystemCommandFailed.new("Message"))
    expect {subject.execute("Fuck off!")}.to raise_error(Osaka::ScriptRunnerError, "Error received while executing: \"Fuck off!\" with message \"Message\"")
  end
  
  it "Should be able to execute an file containing applescript" do
    expect(Osaka::CommandRunner).to receive(:run).with('osascript script.scpt').and_return(true)
    subject.execute_file("script.scpt")
  end
  
  it "Should be able to pass parameters to an applescript" do
    expect(Osaka::CommandRunner).to receive(:run).with('osascript script.scpt a b c').and_return(true)
    subject.execute_file("script.scpt", "a b c")    
  end
  
end
