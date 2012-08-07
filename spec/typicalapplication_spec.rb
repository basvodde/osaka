# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalApplication" do

  include(*Osaka::ApplicationWrapperExpectations)
  
  subject { Osaka::TypicalApplication.new("ApplicationName") }
  
  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
    Osaka::ScriptRunner.enable_debug_prints
  end
  
  after (:each) do
    Osaka::ScriptRunner.disable_debug_prints
  end
  
  it "Should be able to clone TypicalApplications" do
    expect_clone
    subject.clone    
  end
  
  it "Should pass the right open string to the application osascript" do
    filename = "filename.key"
    expect_tell("open \"#{File.absolute_path(filename)}\"")
    expect_set_current_window(filename)
    subject.open(filename)    
  end
  
  it "Should only get the basename of the filename when it sets the window title." do
    filename = "/root/dirname/filename.key"
    expect_tell("open \"#{File.absolute_path(filename)}\"")
    expect_set_current_window("filename.key")
    subject.open(filename)        
  end
  
  it "Should be able to quit" do
    expect_running?.and_return(true)
    expect_quit
    subject.quit
  end
  
  it "Should be able to check if its running" do
    expect_running?.and_return(true)
    subject.running?.should == true
  end
  
  it "Won't quit when the application isn't running" do
    expect_running?.and_return(false)
    subject.quit(:dont_save)  
  end
  
  it "Should be able to quit without saving" do
    expect_running?.and_return(true, true, false)
    expect_quit
    expect_exists(at.sheet(1)).and_return(true)
    expect_click!(at.button("Don’t Save").sheet(1))
    subject.quit(:dont_save)  
  end
  
  it "Should be able to create a new document" do
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("new_window")    
    expect_keystroke("n", :command)
    expect_set_current_window("new_window")
    expect_focus
    subject.new_document
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
    
  it "Should be able to save" do
    expect_keystroke("s", :command)
    subject.save
  end
  
  it "Should be able to save as a file without duplicate being available" do
    subject.should_receive(:duplicate_available?).and_return(false)
    save_dialog = double("Osaka::TypicalSaveDialog")
    subject.should_receive(:save_dialog).and_return(save_dialog)
    save_dialog.should_receive(:save).with("filename")
    expect_set_current_window("filename")
    subject.save_as("filename")
  end

  it "Should be able to save as a file using the duplicate..." do
    new_instance = mock(:TypicalApplication)
    new_instance_wrapper = mock(:ApplicationWrapper)
    save_dialog = double("Osaka::TypicalSaveDialog").as_null_object

    subject.should_receive(:duplicate_available?).and_return(true)
    subject.should_receive(:duplicate).and_return(new_instance)
    new_instance.should_receive(:wrapper).and_return(new_instance_wrapper)
    new_instance_wrapper.should_receive(:clone).and_return(@wrapper)
    
    subject.should_receive(:close)
    subject.should_receive(:save_dialog).and_return(save_dialog)
    expect_set_current_window("filename")
    subject.save_as("filename")    
  end
  
  it "Should be able to check whether Duplicate is supported" do
    expect_exists(at.menu_item("Duplicate").menu(1).menu_bar_item("File").menu_bar(1)).and_return(true)
    subject.duplicate_available?.should == true
  end
  
  it "Should throw an exception when duplicate is not available"do
    subject.should_receive(:duplicate_available?).and_return(false)
    lambda {subject.duplicate}.should raise_error(Osaka::VersioningError, "MacOS Versioning Error: Duplicate is not available on this Mac version")
  end
  
  it "Should return a new keynote instance variable after duplication" do
    new_instance = mock(:TypicalApplication)
    subject.should_receive(:duplicate_available?).and_return(true)
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("duplicate window", "New name duplicate window")
    expect_keystroke("s", [:command, :shift])  
    subject.should_receive(:clone).and_return(new_instance)
    new_instance.should_receive(:wrapper).and_return(@wrapper)
    expect_keystroke!(:return)
    expect_set_current_window("New name duplicate window")
    subject.duplicate.should == new_instance
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
  
  it "Should be able to activate" do
    expect_activate
    subject.activate
  end
  
  it "Should be able to focus" do
    expect_focus
    subject.focus
  end
  
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
  
  it "Should be able to select all" do
    expect_keystroke("a", :command)
    subject.select_all
  end
  
  it "Should be able to retrieve a print dialog" do
    expect_keystroke("p", :command)
    expect_wait_until_exists(at.sheet(1))
    subject.print_dialog
  end
  
  it "Should be able to check whether the save will pop up a dialog or not" do
    expect_exists(at.menu_item("Save…").menu(1).menu_bar_item("File").menu_bar(1)).and_return(true)
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
  
  describe "Application info" do
    it "Should be able to retrieve an application info object and parse it" do
      expect_tell('get info for (path to application "ApplicationName")').and_return('name:ApplicationName.app, creation date:date "Sunday, December 21, 2008 PM 06:14:11"}')
      app_info = subject.get_info
      app_info.name.should == "ApplicationName.app"
    end
  end
  
  describe "Generic Print Dialog" do
    
    subject { Osaka::TypicalPrintDialog.new(at.sheet(1), double(:OSAApp).as_null_object) }

    it "Should be able to save the PDF in a print dialog" do
      save_dialog_mock = double(:GenericSaveDialog)
      
      expect_click!(at.menu_button("PDF").sheet(1)) 
      expect_wait_until_exists!(at.menu(1).menu_button("PDF").sheet(1))
      
      expect_click!(at.menu_item(2).menu(1).menu_button("PDF").sheet(1))
      expect_wait_until_exists!(at.window("Save"), at.sheet(1).window("Print")).and_return(at.window("Save"))

      subject.should_receive(:create_save_dialog).with(at.window("Save"), subject.wrapper).and_return(save_dialog_mock)
      save_dialog_mock.should_receive(:save).with("filename")
      
      expect_until_not_exists!(at.sheet(1))
      expect_click!(at.checkbox(1).sheet(1))
      
      subject.save_as_pdf("filename")
    end
  end
  
  describe "Generic Save Dialog" do
    
    subject { Osaka::TypicalSaveDialog.new(at.sheet(1), double("Osaka::ApplicationWrapper").as_null_object)}
    
    it "Should clone the wrapper and change the window name to Save" do
      app_wrapper = double("Osaka::ApplicationWrapper")
      app_cloned_wrapper = double("Osaka::ApplicationWrapper")
      app_wrapper.should_receive(:clone).and_return(app_cloned_wrapper)
      Osaka::TypicalSaveDialog.new(at.sheet(1), app_wrapper)
    end
    
    it "Should set the filename in the test field" do
      subject.should_receive(:set_filename).with("filename")
      subject.should_receive(:click_save)
      subject.should_not_receive(:set_folder)
      subject.save("filename")
    end
    
    it "Should pick only the base filename when a path is given" do
      subject.should_receive(:set_filename).with("filename")
      subject.should_receive(:set_folder)
      subject.should_receive(:click_save)
      subject.save("/path/filename")
    end
    
    it "Should set the path when a full path is given" do
      @wrapper.as_null_object
      subject.should_receive(:set_filename)
      subject.should_receive(:set_folder).with("/path/second")
      subject.save("/path/second/name")
    end
    
    it "Should be able to click save" do
      expect_click(at.button("Save").sheet(1))
      expect_wait_until_not_exists(at.sheet(1))
      subject.click_save
    end
    
    it "Should be able to set the filename" do
      @wrapper.should_receive(:set).with('value', at.text_field(1).sheet(1), "filename")
      subject.set_filename("filename")
    end
    
    it "Should be able to set the path" do
      expect_keystroke("g", [ :command, :shift ])
      expect_wait_until_exists(at.sheet(1).sheet(1))
      expect_set("value", at.text_field(1).sheet(1).sheet(1), "path")
      expect_click(at.button("Go").sheet(1).sheet(1))
      expect_wait_until_not_exists(at.sheet(1).sheet(1))
      subject.set_folder("path")
    end
  end
end