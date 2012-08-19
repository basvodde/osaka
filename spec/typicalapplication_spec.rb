# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalApplication" do

  include(*Osaka::OsakaExpectations)
  
  subject { Osaka::TypicalApplication.new("ApplicationName") }
  
  let(:control) { subject.control = mock("RemoteControl", :name => "ApplicationName", :base_location => "") }

  before (:each) do
    Osaka::ScriptRunner.enable_debug_prints
  end
  
  after (:each) do
    Osaka::ScriptRunner.disable_debug_prints
  end
  
  it "Should be able to do something and wait until a new window pops up" do
    expect_window_list.and_return(["original window"], ["original window"], ["original window"], ["new window", "original window"])
    expect_activate
    code_block_called = false
    subject.do_and_wait_for_new_window {
      code_block_called = true
    }.should == "new window"
    code_block_called.should == true
  end
  
  context "Cloning and copying" do
    
    it "Should be able to clone TypicalApplications" do
      expect_clone
      subject.clone    
    end
  
    it "Should be able to clone the typical applications and the remote controls will be different" do
      subject.control.set_current_window "Original"
      new_instance = subject.clone
      new_instance.control.set_current_window "Clone"
      subject.control.current_window_name.should == "Original"
    end
  
    it "Should pass the right open string to the application osascript" do
      filename = "filename.key"
      expect_tell("open \"#{File.absolute_path(filename)}\"")
      expect_set_current_window(filename)
      subject.open(filename)    
    end
  end
  
  context "Opening and new document" do
    
    it "Should only get the basename of the filename when it sets the window title." do
      filename = "/root/dirname/filename.key"
      expect_tell("open \"#{File.absolute_path(filename)}\"")
      expect_set_current_window("filename.key")
      subject.open(filename)        
    end
    
    it "Should be able to create a new document" do
      subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("new_window")    
      expect_keystroke("n", :command)
      expect_set_current_window("new_window")
      expect_focus
      subject.new_document
    end
    
  end
  
  context "Quiting and closing and checking whether the app is still running" do
  
    it "Should be able to quit" do
      expect_running?.and_return(true)
      expect_quit
      subject.quit
    end
  
    it "Should be able to check if its running" do
      expect_running?.and_return(true)
      subject.running?.should be_true
    end
  
    it "Won't quit when the application isn't running" do
      expect_running?.and_return(false)
      subject.quit(:dont_save)  
    end
  
    it "Should be able to quit without saving" do
      expect_running?.and_return(true, true, false)
      expect_quit
      expect_exists?(at.sheet(1)).and_return(true)
      expect_click!(at.button("Don’t Save").sheet(1))
      subject.quit(:dont_save)  
    end
    
    it "Should be able to close" do
      expect_keystroke("w", :command)
      subject.close
    end

    it "Should be able to close and don't save" do
      expect_keystroke("w", :command)
      subject.should_receive(:wait_for_window_and_dialogs_to_close).with(:dont_save)
      subject.close(:dont_save)
    end
    
  end
  
  context "Save and duplicate documents" do
    
    let(:save_dialog) { mock("Typical Save Dialog") }
    let(:new_instance_control) { mock("RemoteControl") }
    
    it "Should be able to save" do
      expect_keystroke("s", :command)
      subject.save
    end
  
    it "Should be able to save as a file without duplicate being available" do
      subject.should_receive(:duplicate_available?).and_return(false)
      
      subject.should_receive(:save_dialog).and_return(save_dialog)
      save_dialog.should_receive(:save).with("filename")
      expect_set_current_window("filename")
      
      subject.save_as("filename")
    end

    it "Should be able to save as a file using the duplicate..." do
      subject.should_receive(:duplicate_available?).and_return(true)

      subject.stub_chain(:duplicate, :control, :clone).and_return(new_instance_control)
      subject.should_receive(:close)
      subject.stub_chain(:save_dialog, :save)
      new_instance_control.should_receive(:set_current_window).with("filename")
      
      subject.save_as("filename")
      subject.control.should equal(new_instance_control)   
    end
  
    it "Should be able to check whether Duplicate is supported" do
      expect_exists?(at.menu_item("Duplicate").menu(1).menu_bar_item("File").menu_bar(1)).and_return(true)
      subject.duplicate_available?.should == true
    end
  
    it "Should throw an exception when duplicate is not available"do
      subject.should_receive(:duplicate_available?).and_return(false)
      lambda {subject.duplicate}.should raise_error(Osaka::VersioningError, "MacOS Versioning Error: Duplicate is not available on this Mac version")
    end
  
    it "Should return a new keynote instance variable after duplication" do
      subject.should_receive(:duplicate_available?).and_return(true)

      subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("duplicate window", "New name duplicate window")
      expect_keystroke("s", [:command, :shift])  

      subject.stub_chain(:clone, :control).and_return(new_instance_control)
      subject.should_receive(:sleep).with(0.4) # Avoiding Mountain Lion crash
      expect_keystroke!(:return)
      new_instance_control.should_receive(:set_current_window).with("New name duplicate window")
      subject.duplicate.control.should equal(new_instance_control)
    end
    
    it "Should be able to check whether the save will pop up a dialog or not" do
      expect_exists?(at.menu_item("Save…").menu(1).menu_bar_item("File").menu_bar(1)).and_return(true)
      subject.save_pops_up_dialog?.should == true
    end

    it "Should be able to retrieve a save dialog by using save as" do
      subject.should_receive(:save_pops_up_dialog?).and_return(false)
      expect_keystroke("s", [:command, :shift])
      expect_wait_until_exists(at.sheet(1))
      subject.save_dialog    
    end

    it "Should be able to retrieve a save dialog using duplicate and save" do
      subject.should_receive(:save_pops_up_dialog?).and_return(true)
      subject.should_receive(:save)
      expect_wait_until_exists(at.sheet(1))
      subject.save_dialog
    end
    
  end
    
  it "Should be able to activate" do
    expect_activate
    subject.activate
  end
  
  it "Should be able to focus" do
    expect_focus
    subject.focus
  end
  
  context "Copy pasting" do

    it "Should be able to copy" do
      expect_keystroke("c", :command)
      subject.copy
    end

    it "Should be able to paste" do
      expect_keystroke("v", :command)
      subject.paste  
    end

    it "Should be able to cut" do
      expect_keystroke("x", :command)
      subject.cut
    end
    
  end
    
  context "Selecting things" do
    it "Should be able to select all" do
      expect_keystroke("a", :command)
      subject.select_all
    end
  end

  context "Printing" do
    
    it "Should be able to retrieve a print dialog" do
      expect_keystroke("p", :command)
      expect_wait_until_exists(at.sheet(1))
      subject.print_dialog
    end
  end
    
  describe "Application info" do
    it "Should be able to retrieve an application info object and parse it" do
      expect_tell('get info for (path to application "ApplicationName")').and_return('name:ApplicationName.app, creation date:date "Sunday, December 21, 2008 PM 06:14:11"}')
      app_info = subject.get_info
      app_info.name.should == "ApplicationName.app"
    end
  end
  
end