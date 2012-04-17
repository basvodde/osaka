
require 'osaka'

describe "Osaka::ApplicationWrapper" do

  name = "ApplicationName"
  quoted_name = "\"#{name}\""
  subject { Osaka::ApplicationWrapper.new(name) }

  it "Should be able to clone wrappers" do
    subject.window = "Window"
    new_wrapper = subject.clone
    new_wrapper.should == subject
    new_wrapper.should_not.equal?(subject)
  end
  
  it "Should be able to compare objects using names" do
    subject.should == Osaka::ApplicationWrapper.new(name)
    subject.should_not == Osaka::ApplicationWrapper.new("otherName")
  end
  
  it "Should be able to compare objects using window" do
    equal_object = Osaka::ApplicationWrapper.new(name)
    unequal_object = Osaka::ApplicationWrapper.new(name)
    equal_object.window = subject.window = "Window"
    unequal_object.window = "Another Window"
    
    subject.should == equal_object
    subject.should_not == unequal_object
  end
  
  def check_for_warning(action)
    Osaka::ScriptRunner.should_receive(:execute).and_return("Blah")
    subject.should_receive(:print_warning).with(action, "Blah")
  end
  
  it "Should be able to tell applications to do something" do
    Osaka::ScriptRunner.should_receive(:execute).with("tell application #{quoted_name}; command; end tell")
    subject.tell("command")
  end

  it "Can also pass multi-line commands to telling an application what to do" do
    Osaka::ScriptRunner.should_receive(:execute).with("tell application #{quoted_name}; activate; quit; end tell")
    subject.tell("activate; quit")
  end
  
  it "Should be able to print warning messages" do
    subject.should_receive(:puts).with("Osaka WARNING while doing action: Message")
    subject.print_warning("action", "Message")
  end

  it "Should print an Warning message with the ScriptRunner returns text when doing activate" do
    check_for_warning("activate")
    subject.activate
  end
  
  it "Has a short-cut method for quitting" do
    subject.should_receive(:keystroke).with("q", :command)
    subject.quit
  end
  
  it "Should be able to generate events via the Systems Events" do
    Osaka::ScriptRunner.should_receive(:execute).with(/tell application "System Events"; tell process #{quoted_name}; quit; end tell; end tell/)
    subject.system_event!("quit")
  end

  it "Should be able to generate events via the Systems Events and activate the application first" do
    subject.should_receive(:activate)
    subject.should_receive(:system_event!).with("quit")
    subject.system_event("quit")
  end
  
  it "Should be able to check whether a specific element exists" do
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window 1/).and_return("true\n")
    subject.check.exists("window 1").should == true
  end
  
  it "Should be able to wait for for a specific element existing" do
    counter = 0
    Osaka::ScriptRunner.should_receive(:execute).exactly(5).times.with(/exists window 1/).and_return {
      counter = counter + 1
      (counter == 5).to_s
    }
    subject.wait_until!.exists("window 1")
  end
  
  it "Should be able to wait until exists and activate the application first" do
    subject.should_receive(:activate)
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window 1/).and_return("true")
    subject.wait_until.exists("window 1")
  end

  it "Should be able to wait for a specific element to not exist anymore" do
    Osaka::ScriptRunner.should_receive(:execute).with(/not exists window 1/).and_return("true")
    subject.wait_until!.not_exists("window 1")    
  end
  
  it "Should be able to generate keystroke events" do
    Osaka::ScriptRunner.should_receive(:execute).with(/keystroke "p"/).and_return("")
    subject.keystroke!("p")
  end

  it "Prints a warning when keystroke results in some outputShould be able to generate keystroke events" do
    check_for_warning("keystroke")
    subject.keystroke!("p")
  end
  
  it "Should be able to keystroke and activate" do
    subject.should_receive(:activate)
    subject.should_receive(:focus)
    subject.should_receive(:keystroke!).with("a", [])
    subject.keystroke("a", [])        
  end
  
  it "Should be able to do keystrokes with command down" do
    Osaka::ScriptRunner.should_receive(:execute).with(/keystroke "p" using {command down}/).and_return("")
    subject.keystroke!("p", :command)    
  end

  it "Should be able to do keystrokes with option and command down" do
    Osaka::ScriptRunner.should_receive(:execute).with(/keystroke "p" using {option down, command down}/).and_return("")
    subject.keystroke!("p", [ :option, :command ])    
  end
  
  it "Should be able to do a keystroke and wait until something happen in one easy line" do
    Osaka::ScriptRunner.should_receive(:execute).with(/keystroke "p"/).and_return("")
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window 1/).and_return("true")
    subject.keystroke!("p", []).wait_until!.exists("window 1")
  end
  
  it "Should be able to keystroke_and_wait_until_exists and activate" do
    subject.should_receive(:activate)
    subject.should_receive(:focus)
    Osaka::ScriptRunner.should_receive(:execute).with(/keystroke "p"/).and_return("")
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window 1/).and_return("true")
    subject.keystroke("p", []).wait_until!.exists("window 1")    
  end
  
  it "Should be able to do clicks" do
    Osaka::ScriptRunner.should_receive(:execute).with(/click menu button "PDF"/).and_return("")
    subject.click!('menu button "PDF"')
  end

  it "Should be able to do click and activate" do
    subject.should_receive(:activate)
    subject.should_receive(:click!).with("button")
    subject.click("button")    
  end
  
  it "Should be able to do clicks and wait until something happened in one easy line" do
    Osaka::ScriptRunner.should_receive(:execute).with(/click/).and_return("")
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window/).and_return("true")
    subject.click!("button").wait_until!.exists("window")
  end
  
  it "Should be able to click_and_wait_until_exists and activate" do
    subject.should_receive(:activate)
    Osaka::ScriptRunner.should_receive(:execute).with(/click/).and_return("")
    Osaka::ScriptRunner.should_receive(:execute).with(/exists window/).and_return("true")
    subject.click("button").wait_until!.exists("window")
  end
    
  it "Should be able to set a value to an element" do
    subject.should_receive(:system_event!).with(/set value of window to "newvalue"/).and_return("")
    subject.set!("value", "window", "newvalue")
  end

  it "Prints a warning when setting and element and output is received" do
    check_for_warning("set")
    subject.set!("value", "window", "newvalue")
  end
  
  it "Should be able to set to boolean values" do
    subject.should_receive(:system_event!).with(/set value of window to true/).and_return("")
    subject.set!("value", "window", true)    
  end
    
  it "Should be able to get a value from an element" do
    subject.should_receive(:system_event!).with(/get value of window/).and_return("1\n")
    subject.get!("value", "window").should == "1"
  end
  
  it "Should use the locally stored window when that one is set." do
    subject.window = "1"
    subject.should_receive(:system_event!).with(/get value of window \"1\"/).and_return("1\n")
    subject.get!("value").should == "1"
  end
  
  it "Should throw an exception when window is set multiple times." do
    subject.window = "Untitled"
    lambda {subject.get!("value", "window 1")}.should raise_error(Osaka::InvalidLocation, "Invalid location for command: of window 1 of window \"Untitled\"")
  end
  
  it "Should combine the location and the window" do
    subject.window = "1"
    subject.should_receive(:system_event!).with(/get value of dialog 2 of window "1"/).and_return("1\n")
    subject.get!("value", "dialog 2").should == "1"    
  end
  
  it "Should be able to get values from the application itself" do
    subject.should_receive(:system_event!).with("get value").and_return("1\n")
    subject.get_app!("value").should == "1"
  end
    
  it "Should be able to set a value and activate" do
    subject.should_receive(:activate)
    subject.should_receive(:set!).with("value", "window", "newvalue")
    subject.set("value", "window", "newvalue")
  end
    
  it "Should be able to loop over some script until something happens" do
    counter = 0
    Osaka::ScriptRunner.should_receive(:execute).exactly(3).times.with(/exists window/).and_return {
      counter = counter + 1
      if counter > 2
        "true"
      else
        "false"
      end
    }
    subject.should_receive(:activate).twice
    subject.until!.exists("window") {
      subject.activate
    }
  end
  
  it "Should be able to get an empty array when requesting for the window list and there are none" do
    subject.should_receive(:get_app!).with("windows").and_return("\n")
    subject.window_list.should == []
  end
  
  it "Should be able get an array with one window name when there is exactly one window" do
    subject.should_receive(:get_app!).with("windows").and_return("window one of application process process\n")
    subject.window_list.should == ["one"]    
  end
  
  it "Should be able to get an array of multiple window names" do
    subject.should_receive(:get_app!).with("windows").and_return("window one of application process process, window two of application process process\n")
    subject.window_list.should == ["one", "two"]    
  end
  
  it "Should initialize the current window when it is not focused yet" do
    subject.should_receive(:window_list).and_return(["1"])
    subject.focus
    subject.window.should == "1"
  end
  
  it "Shouldn't initialize current window when it is already set" do
    subject.should_receive(:window_list).and_return(["1"])
    subject.focus

    subject.should_receive(:window_list).and_return(["2", "1"])
    subject.should_receive(:set!)
    subject.focus
    subject.window.should == "1"
  end
  
  it "Should re-initialize the current window when it doesn't exist anymore" do
    subject.should_receive(:window_list).and_return(["1"])
    subject.focus

    subject.should_receive(:window_list).and_return(["2"])
    subject.focus
    subject.window.should == "2"    
  end
  
  it "Should focus the current window when it doesn't have focus" do
    subject.should_receive(:window_list).and_return(["1"])
    subject.focus

    subject.should_receive(:window_list).and_return(["2", "1"])
    subject.should_receive(:set!).with("value", "attribute \"AXMain\" of window \"1\"", true )
    subject.focus
  end  
  
end