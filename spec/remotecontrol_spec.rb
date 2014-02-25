
require 'osaka'

describe "Osaka::RemoteControl" do

  include(*Osaka::OsakaExpectations)

  name = "ApplicationName"

  subject { Osaka::RemoteControl.new(name) }
  let(:control) { subject }

  before (:each) do
    Osaka::ScriptRunner.enable_debug_prints
  end
  
  after (:each) do
    Osaka::ScriptRunner.disable_debug_prints
  end

  def expect_execute_and_warning_for(action)
    expect_execute_osascript.and_return("An Error")
    subject.should_receive(:puts).with(/#{action}/)
  end
  
  it "Should be able to print warning messages" do
    subject.should_receive(:puts).with("Osaka WARNING while doing ThisAction: Message")
    subject.print_warning("ThisAction", "Message")
  end
  
  context "Query things from the OS" do

    it "Should be possible to check whether an application is still running" do
      expect_execute_osascript("tell application \"System Events\"; (name of processes) contains \"#{name}\"; end tell").and_return("false")
      subject.running?.should be_false
    end
    
    it "Can get the OS version (lion)" do
      expect_execute_osascript("system version of (system info)").and_return("10.7.4\n")
      subject.mac_version.should == :lion
      subject.mac_version_string.should == "10.7.4"
    end

    it "Can get the OS version (mountain lion)" do
      expect_execute_osascript("system version of (system info)").and_return("10.8\n")
      subject.mac_version.should == :mountain_lion
    end

    it "Can get the OS version (snow leopard)" do
      expect_execute_osascript("system version of (system info)").and_return("10.6\n")
      subject.mac_version.should == :snow_leopard
    end

    it "Can get the OS version (snow leopard)" do
      expect_execute_osascript("system version of (system info)").and_return("1\n")
      subject.mac_version.should == :other
    end
  end  

  context "Able to compare different remote controls" do
    
    it "Should be able to clone controls" do
      subject.set_current_window "Window"
      new_control = subject.clone
      new_control.should == subject
      new_control.should_not equal(subject)
    end
    
    it "Should be having different current window instances when cloning" do
      subject.set_current_window "Window"
      new_control = subject.clone
      new_control.set_current_window "Not the same"
      subject.current_window_name.should_not == new_control.current_window_name
      
    end
  
    it "Should be able to compare objects using names" do
      subject.should == Osaka::RemoteControl.new(name)
      subject.should_not == Osaka::RemoteControl.new("otherName")
    end
  
    it "Should be able to compare objects using window" do
      equal_object = Osaka::RemoteControl.new(name)
      unequal_object = Osaka::RemoteControl.new(name)
      equal_object.set_current_window("Window")
      subject.set_current_window("Window")
      unequal_object.set_current_window "Another Window"
    
      subject.should == equal_object
      subject.should_not == unequal_object
    end
  end
  
  context "Basic control functionality of telling and sending system events" do

    quoted_name = "\"#{name}\""

    it "Should be able to tell applications to do something" do
      expect_execute_osascript("tell application #{quoted_name}; command; end tell")
      subject.tell("command")
    end

    it "Can also pass multi-line commands to telling an application what to do" do
      expect_execute_osascript("tell application #{quoted_name}; command1; command2; end tell")
      subject.tell("command1; command2")
    end

    it "Should be able to generate events via the Systems Events" do
      expect_execute_osascript(/tell application "System Events"; tell process #{quoted_name}; quit; end tell; end tell/)
      subject.system_event!("quit")
    end

    it "Should be able to generate events via the Systems Events (with activate)" do
      expect_activate
      expect_system_event!("quit")
      subject.system_event("quit")
    end
  end
  
  context "Check whether things exist or not" do
    
    it "Should be able to check whether a location exists" do
      expect_execute_osascript(/exists button 1/).and_return("true\n")
      subject.exists?(at.button(1)).should be_true
    end

    it "Should be able to check whether a location does not exists" do
      expect_execute_osascript(/not exists window 1/).and_return("true\n")
      subject.not_exists?(at.window(1)).should be_true
    end
  end
  
  context "Waiting and doing until elements exist or not" do
  
    it "Should be able to wait for only one location to exist" do
      expect_exists?(at.button(1)).and_return(false, false, true)
      subject.wait_until_exists!(at.button(1)).should == at.button(1)
    end

    it "Should be able to wait for only one location to exist (with activate)" do
      expect_activate
      expect_exists?(at.button(1)).and_return(false, false, true)
      subject.wait_until_exists(at.button(1)).should == at.button(1)
    end
      
    it "Should be able to wait until multiple locations exists and return the one that happened" do
      expect_exists?(at.button(1)).and_return(false, false, false)
      expect_exists?(at.sheet(5)).and_return(false, false, true)
      subject.wait_until_exists!(at.button(1), at.sheet(5)).should == at.sheet(5)
    end

    it "Should be able to wait until multiple locations exists and return the one that happened (with activate)" do
      expect_activate
      expect_exists?(at.button(1)).and_return(false, false)
      expect_exists?(at.sheet(5)).and_return(false, true)
      subject.wait_until_exists(at.button(1), at.sheet(5)).should == at.sheet(5)
    end
    
    it "Should be able to wait for one location to NOT exist" do
      expect_not_exists?(at.button(1)).and_return(false, false, true)
      subject.wait_until_not_exists!(at.button(1)).should == at.button(1)      
    end

    it "Should be able to wait for one location to NOT exist (with activate)" do
      expect_activate
      expect_not_exists?(at.button(4)).and_return(false, true)
      subject.wait_until_not_exists(at.button(4)).should == at.button(4)      
    end
    
    it "Should be able to loop over some script until something happens" do
      Timeout.should_receive(:timeout).with(10).and_yield
      expect_execute_osascript.and_return("false", "false", "true")
      expect_activate.twice
      
      
      subject.until_exists!(at.window(1)) {
        subject.activate
      }
    end
    
    it "Should print a proper error message when it times out while waiting for something" do
      Timeout.should_receive(:timeout).with(10).and_raise(Timeout::Error.new)
      expect { subject.until_exists!(at.window(1)) }.to raise_error(Osaka::TimeoutError, "Timed out while waiting for: window 1")
    end

    it "Should print a proper error message when it times out while waiting for more than one thing" do
      Timeout.should_receive(:timeout).with(10).and_raise(Timeout::Error.new)
      expect { subject.until_exists!(at.window(1), at.button(2)) }.to raise_error(Osaka::TimeoutError, "Timed out while waiting for: window 1, button 2")
    end
  end

  context "Short convenient methods for different actions" do

    it "Has a short-cut method for quitting" do
      expect_keystroke("q", :command)
      subject.quit
    end

    it "Should print an Warning message with the ScriptRunner returns text when doing activate" do
      expect_execute_and_warning_for("activate")
      subject.activate
    end
    
    it "Should be able to launch and deal with the warning" do
      expect_execute_and_warning_for("launch")
      subject.launch      
    end
  end
    
    

  context "Can send keystrokes to the application" do
  
    it "Should be able to generate keystroke events" do
      expect_execute_osascript(/keystroke "p"/).and_return("")
      subject.keystroke!("p")
    end

    it "Should be able to generate return keystroke event" do
      expect_execute_osascript(/keystroke return/).and_return("")
      subject.keystroke!(:return)
    end

    it "Prints a warning when keystroke results in some outputShould be able to generate keystroke events" do
      expect_execute_and_warning_for("keystroke")
      subject.keystroke!("p")
    end

    it "Should be able to keystroke and activate" do
      expect_activate
      expect_focus
      expect_keystroke!("a")
      subject.keystroke("a")        
    end

    it "Should be able to do keystrokes with command down" do
      expect_execute_osascript(/keystroke "p" using {command down}/).and_return("")
      subject.keystroke!("p", :command)    
    end

    it "Should be able to do keystrokes with option and command down" do
      expect_execute_osascript(/keystroke "p" using {option down, command down}/).and_return("")
      subject.keystroke!("p", [ :option, :command ])    
    end

    it "Should be able to do a keystroke and wait until something happen in one easy line" do
      expect_execute_osascript(/keystroke "p"/).and_return("")
      expect_execute_osascript(/exists window 1/).and_return("true")
      subject.keystroke!("p", []).wait_until_exists!(at.window(1))
    end

    it "Should be able to keystroke_and_wait_until_exists and activate" do
      expect_activate
      expect_focus
      expect_execute_osascript(/keystroke "p"/).and_return("")
      expect_execute_osascript(/exists window 1/).and_return("true")
      subject.keystroke("p").wait_until_exists!(at.window(1))    
    end
    
  end
  
  context "Can send mouse clicks to the application" do

    it "Should be able to do clicks" do
      expect_execute_osascript(/click menu button "PDF"/).and_return("")
      subject.click!(at.menu_button("PDF"))
    end

    it "Should be able to do click and activate" do
      expect_activate
      expect_click!("button")
      subject.click("button")    
    end

    it "Should be able to do clicks and wait until something happened in one easy line" do
      expect_execute_osascript(/click/).and_return("")
      expect_execute_osascript(/exists window 1/).and_return("true")
      subject.click!("button").wait_until_exists!(at.window(1))
    end

    it "Should be able to click_and_wait_until_exists and activate" do
      expect_activate
      expect_execute_osascript(/click/).and_return("")
      expect_execute_osascript(/exists window 1/).and_return("true")
      subject.click("button").wait_until_exists!(at.window(1))
    end

    it "Should be able to click on menu bar items" do
      expect_activate
      expect_click!(at.menu_item("Hey").menu(1).menu_bar_item("File").menu_bar(1))
      subject.click_menu_bar(at.menu_item("Hey"), "File")    
    end
    
  end
  
  context "Control should be able to set and get different application values" do

    it "Should be able to set a value to an element" do
      expect_system_event!(/set value of window 1 to "newvalue"/).and_return("")
      subject.set!("value", at.window(1), "newvalue")
    end
    
    it "Prints a warning when setting and element and output is received" do
      expect_execute_and_warning_for("set")
      subject.set!("value", at.window(1), "newvalue")
    end

    it "Should be able to set to boolean values" do
      expect_system_event!(/set value of window 1 to true/).and_return("")
      subject.set!("value", at.window(1), true)    
    end

    it "Should be able to get a value from an element" do
      expect_system_event!(/get value of window 1/).and_return("1\n")
      subject.get!("value", at.window(1)).should == "1"
    end

    it "Should use the locally stored window when that one is set." do
      subject.set_current_window("1")
      expect_system_event!(/get value of window \"1\"/).and_return("1\n")
      subject.get!("value").should == "1"
    end

    it "Should combine the location and the window" do
      subject.set_current_window("1")
      expect_system_event!(/get value of dialog 2 of window "1"/).and_return("1\n")
      subject.get!("value", at.dialog(2)).should == "1"    
    end

    it "Should be able to get values from the application itself" do
      expect_system_event!("get value").and_return("1\n")
      subject.get_app!("value").should == "1"
    end

    it "Should be able to set a value and activate" do
      expect_activate
      expect_set!("value", at.window(1), "newvalue")
      subject.set("value", at.window(1), "newvalue")
    end

    it "Should be able to get an empty array when requesting for the window list and there are none" do
      expect_get_app!("windows").and_return("\n")
      subject.window_list.should == []
    end

    it "Should be able get an array with one window name when there is exactly one window" do
      expect_get_app!("windows").and_return("window one of application process process\n")
      subject.window_list.should == ["one"]    
    end
    
    it "Should be able to get a list of standard windows which is empty" do
      subject.should_receive(:window_list).and_return([])
      subject.standard_window_list
    end
    
    it "Should be able to get a list of all the standard windows when there are only standard windows " do
      subject.should_receive(:window_list).and_return(["window 1"])
      expect_get!("subrole", at.window("window 1")).and_return("AXStandardWindow")
      subject.standard_window_list.should == ["window 1"]
    end
    
    it "Should be able to get a list of all the standard windows excluding the floating ones" do
      subject.should_receive(:window_list).and_return(["window", "float"])
      expect_get!("subrole", at.window("window")).and_return("AXStandardWindow")
      expect_get!("subrole", at.window("float")).and_return("AXFloatingWindow")
      subject.standard_window_list.should == ["window"]      
    end
    
    it "Should be able to get the attributes of a window and parse the result" do
      expect_get!("attributes", at.window(1)).and_return("attribute AXRole of window 1 of application process ApplicationName, attribute AXRoleDescription of window 1 of application process ApplicationName, attribute AXSubrole of window 1 of application process ApplicationName")
      subject.attributes(at.window(1)).should == ["AXRole", "AXRoleDescription", "AXSubrole"]
    end

    it "Should be able to get the attributes of the application too" do
    expect_get!("attributes", at.window(1)).and_return("attribute AXRole of application process ApplicationName, attribute AXRoleDescription of application process ApplicationName")
      subject.attributes(at.window(1)).should == ["AXRole", "AXRoleDescription"]
    end
    
  end

  describe "Dealing with base locations and window lists" do

    it "Should be possible to pass a base location in the creation" do
      subject = Osaka::RemoteControl.new("Application", at.window("Window"))
      subject.base_location.should == at.window("Window")
    end

    it "Should be able to get an array of multiple window names" do
      expect_get_app!("windows").and_return("window one of application process process, window two of application process process\n")
      subject.window_list.should == ["one", "two"]    
    end
    
    it "Should be able to focus the currently active window" do
      subject.base_location = at.sheet(1).window("boo")
      expect_system_event!("set value of attribute \"AXMain\" of window \"boo\" to true")
      subject.focus!
    end
    
    it "Should initialize the current window when it is not focused yet" do      
      expect_window_list.and_return(["1"])
      expect_focus!
      subject.focus
      subject.current_window_name.should == "1"
    end
    
    it "Should be able to extract the current window name also when the base location has more than just a window " do
      subject.base_location = at.sheet(1).window("Window")
      subject.current_window_name.should == "Window"      
    end

    it "Shouldn't initialize current window when it is already set" do
      subject.set_current_window("1")
      expect_not_exists?(at.window("1")).and_return(false)
      expect_focus!
      
      subject.focus
      subject.base_location.should == at.window("1")
    end
    
    it "Should re-initialize the current window when it doesn't exist anymore" do
      subject.set_current_window("1")
      expect_not_exists?(at.window("1")).and_return(true)
      expect_window_list.and_return(["2"])
      expect_focus!
            
      subject.focus
      subject.current_window_name.should == "2"    
    end

    it "Should focus the current window when it doesn't have focus" do
      subject.set_current_window("1")
      expect_not_exists?(at.window("1")).and_return(false)
      expect_focus!
      subject.focus
    end
    
    it "Shouldn't focus when there is no window set at all" do
      expect_window_list.and_return([""])
      subject.focus
    end
    
  end 
end