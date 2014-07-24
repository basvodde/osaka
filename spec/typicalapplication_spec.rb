# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalApplication" do

  include(*Osaka::OsakaExpectations)
  
  subject { Osaka::TypicalApplication.new("ApplicationName") }
  
  let(:control) { subject.control = double("RemoteControl", :name => "ApplicationName", :base_location => "base", :mac_version => :mountain_lion) }

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
  
  end
  
  context "Opening and new document" do
    
    it "Should pass the right open string to the application osascript" do
      filename = "filename.key"
      expect_tell("open \"#{File.absolute_path(filename)}\"")
      subject.stub(:do_and_wait_for_new_window).and_yield.and_return(filename)
      expect_set_current_window(filename)
      subject.open(filename)    
    end

    it "Should only get the basename of the filename when it sets the window title." do
      filename = "/root/dirname/filename.key"
      subject.should_receive(:do_and_wait_for_new_window).and_return("filename")
      expect_set_current_window("filename")
      subject.open(filename)        
    end
    
    it "Should be able to create a new document" do
      subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("new_window")    
      expect_keystroke("n", :command)
      expect_set_current_window("new_window")
      expect_focus
      subject.new_document
    end
    
    it "Should be able to easily create a document, put something, save it, and close it again" do

      subject.should_receive(:new_document)
      subject.should_receive(:method_call_from_code_block)
      subject.should_receive(:save_as).with("filename")
      subject.should_receive(:close)

      subject.create_document("filename") { |doc|
        doc.method_call_from_code_block
      }
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
      subject.running?.should equal true
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
    
    let(:save_dialog) { double("Typical Save Dialog") }
    let(:new_instance_control) { double("RemoteControl") }
    
    it "Should be able to save" do
      expect_keystroke("s", :command)
      subject.save
    end

    it "Should be able to save as a file without duplicate being available" do
      subject.should_receive(:save_pops_up_dialog?).and_return(false)
      subject.should_receive(:duplicate_available?).and_return(false)
      
      expect_keystroke("s", [:command, :shift])
      subject.should_receive(:wait_for_save_dialog_and_save_file).with("filename")
      
      subject.save_as("filename")
    end

    it "Should be able to save as a file using the duplicate..." do
      subject.should_receive(:save_pops_up_dialog?).and_return(false)
      subject.should_receive(:duplicate_available?).and_return(true)

      subject.should_receive(:duplicate_and_close_original)
      subject.should_receive(:save)
      subject.should_receive(:wait_for_save_dialog_and_save_file).with("filename")      
      subject.save_as("filename")
    end
    
    it "Should be able to use normal Save when that pops up a dialog instead of save_as" do
      subject.should_receive(:save_pops_up_dialog?).and_return(true)
      subject.should_receive(:save)
      subject.should_receive(:wait_for_save_dialog_and_save_file).with("filename")      
      subject.save_as("filename")
    end
    
    it "Should be able to wait for a save dialog and save the file" do
      expect_wait_until_exists(at.sheet(1))
      subject.should_receive(:create_dialog).with(Osaka::TypicalSaveDialog, at.sheet(1)).and_return(save_dialog)
      save_dialog.should_receive(:save).with("/tmp/filename")
      expect_set_current_window("filename")
      subject.wait_for_save_dialog_and_save_file("/tmp/filename")
    end
    
    it "Should be able to pick a file from an open dialog" do
      dialog_mock = double("Open Dialog")
      subject.should_receive(:create_dialog).with(Osaka::TypicalOpenDialog, at.window("dialog")).and_return(dialog_mock)
      dialog_mock.should_receive(:set_folder).with("/tmp")
      dialog_mock.should_receive(:select_file).with("filename")
      
      subject.select_file_from_open_dialog("/tmp/filename", at.window("dialog"))
    end
    
    
    it "Should be able to duplicate and close the original document" do
      duplicate = double("DuplicateDocument")
      subject.control.should_receive(:current_window_name).and_return("window name")
      subject.should_receive(:duplicate).and_return(duplicate)
      subject.control.should_receive(:click_menu_bar_by_name).with("window name", "Window")
      subject.should_receive(:close)
      duplicate.should_receive(:control).and_return(new_instance_control)
      subject.duplicate_and_close_original
      subject.control.should equal(new_instance_control)
    end
    
    it "Should be able to check whether Duplicate is supported" do
      expect_exists?(at.menu_item("Duplicate").menu(1).menu_bar_item("File").menu_bar(1)).and_return(true)
      subject.duplicate_available?.should == true
    end
  
    it "Should throw an exception when duplicate is not available"do
      subject.should_receive(:duplicate_available?).and_return(false)
      expect {subject.duplicate}.to raise_error(Osaka::VersioningError, "MacOS Versioning Error: Duplicate is not available on this Mac version")
    end

    it "Should return a new keynote instance variable after duplication (Lion!)" do
      simulate_mac_version(:lion)
      subject.should_receive(:duplicate_available?).and_return(true)
      
      expect_click_menu_bar(at.menu_item("Duplicate"), "File")
      subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("duplicate window")

      subject.stub_chain(:clone, :control).and_return(new_instance_control)
      subject.duplicate.control.should equal(new_instance_control)
    end
  
    it "Should return a new keynote instance variable after duplication" do
      subject.should_receive(:duplicate_available?).and_return(true)

      expect_click_menu_bar(at.menu_item("Duplicate"), "File")
      subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("duplicate window", "New name duplicate window")

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
    
  end
    
  it "Should be able to activate" do
    expect_activate
    subject.activate
  end
  
  it "Should be able to activate and launch. This is done because activate alone in Lion lead to strange behavior" do
    simulate_mac_version(:lion)
    expect_running?.and_return(false)
    expect_launch
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
    
  context "Application info" do
    it "Should be able to retrieve an application info object and parse it" do
      expect_tell('get info for (path to application "ApplicationName")').and_return('name:ApplicationName.app, creation date:date "Sunday, December 21, 2008 PM 06:14:11"}')
      app_info = subject.get_info
      app_info.name.should == "ApplicationName.app"
    end
  end
  
  context "Simple Application helpers to create objects" do
    it "Should be able to create dialogs with a helper" do
      Osaka::TypicalSaveDialog.should_receive(:new).with(control.name, at.sheet(1) + control.base_location)
      subject.create_dialog(Osaka::TypicalSaveDialog, at.sheet(1))
    end
    
    it "Should be able to create top level dialogs also with the helper" do
      Osaka::TypicalSaveDialog.should_receive(:new).with(control.name, at.window("toplevel"))
      subject.create_dialog(Osaka::TypicalSaveDialog, at.window("toplevel"))
    end
  end
  
  it "Should be able to check whether any standard windows are open and do nothing if there aren't" do
    expect_standard_window_list.and_return([])
    subject.raise_error_on_open_standard_windows("error message")
  end

  it "Should be able to check whether any standard windows are open and raise an error if so" do
    expect_standard_window_list.and_return(["Window"])
    expect {
      subject.raise_error_on_open_standard_windows("error message")
    }.to raise_error(Osaka::ApplicationWindowsMustBeClosed, "error message")
  end

  it "Should do nothing is there template chooser is not open" do
    subject.stub(:focus)
    subject.should_receive(:template_chooser?).and_return(false)
    subject.close_template_chooser_if_any
  end
    
  
end