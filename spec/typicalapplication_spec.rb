
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
  
  it "Should pass the right open string to the application osascript" do
    filename = "filename.key"
    expect_tell("open \"#{File.absolute_path(filename)}\"")
    @wrapper.should_receive(:set_current_window).with(filename)
    subject.open(filename)    
  end
  
  it "Should only get the basename of the filename when it sets the window title." do
    filename = "/root/dirname/filename.key"
    expect_tell("open \"#{File.absolute_path(filename)}\"")
    @wrapper.should_receive(:set_current_window).with("filename.key")
    subject.open(filename)        
  end
  
  it "Should be able to quit" do
    @wrapper.should_receive(:running?).and_return(true)
    @wrapper.should_receive(:quit)
    subject.quit
  end
  
  it "Should be able to check if its running" do
    @wrapper.should_receive(:running?)
    subject.running?
  end
  
  it "Won't quit when the application isn't running" do
    @wrapper.should_receive(:running?).and_return(false)
    subject.quit(:dont_save)  
  end
  
  it "Should be able to quit without saving" do
    @wrapper.should_receive(:running?).and_return(true, true, false)
    @wrapper.should_receive(:quit)
    should_check!(:exists, at.sheet(1), true)
    expect_click!(at.button(2).sheet(1))
    subject.quit(:dont_save)  
  end
  
  it "Should be able to wait until a new window exists" do
    subject.wrapper.should_receive(:window_list).and_return(["new window"])
    subject.wait_for_new_window([])    
  end
  
  it "Should be able to wait until a new window exists and it takes 4 calls" do
    counter = 0
    subject.wrapper.should_receive(:window_list).exactly(4).times.and_return(["new window"]) {
        counter = counter + 1
        counter.should <= 5 # Added here so that the test won't end up in an endless loop.
        counter >= 4 ? [ "new window" ] : []
      }
      subject.wait_for_new_window([])    
  end
  
  it "Should be able to create a new document" do    
    subject.wrapper.should_receive(:window_list)
    expect_keystroke("n", :command)
    subject.should_receive(:wait_for_new_window).and_return("new_window")
    subject.wrapper.should_receive(:set_current_window).with("new_window")
    subject.wrapper.should_receive(:focus)
    subject.new_document
  end
  
  it "Should be able to save" do
    expect_keystroke("s", :command)
    subject.save
  end
  
  it "Should be able to save as a file" do
    save_dialog = double("Osaka::TypicalSaveDialog")
    subject.should_receive(:save_dialog).and_return(save_dialog)
    save_dialog.should_receive(:save).with("filename")
    subject.wrapper.should_receive(:set_current_window).with("filename")
    subject.save_as("filename")
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
    @wrapper.should_receive(:activate)
    subject.activate
  end
  
  it "Should be able to focus" do
    @wrapper.should_receive(:focus)
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
    should_wait_until(:exists, at.sheet(1))
    subject.print_dialog
  end
  
  it "Should be able to retrieve a save dialog" do
    expect_keystroke("s", [:command, :shift])
    should_wait_until(:exists, at.sheet(1))
    subject.save_dialog    
  end
  
  describe "Application info" do
    it "Should be able to retrieve an application info object and parse it" do
      @wrapper.should_receive(:tell).with('get info for (path to application "ApplicationName")').and_return('name:ApplicationName.app, creation date:date "Sunday, December 21, 2008 PM 06:14:11"}')
      app_info = subject.get_info
      app_info.name.should == "ApplicationName.app"
    end
  end
  
  describe "Generic Print Dialog" do
    
    subject { Osaka::TypicalPrintDialog.new(at.sheet(1), double(:OSAApp).as_null_object) }

    it "Should be able to save the PDF in a print dialog" do
      save_dialog_mock = double(:GenericSaveDialog)
      
      expect_click!(at.menu_button("PDF").sheet(1)) 
      should_wait_until!(:exists, at.menu(1).menu_button("PDF").sheet(1))
      
      expect_click!(at.menu_item(2).menu(1).menu_button("PDF").sheet(1))
      should_wait_until!(:exists, at.window("Save"))

      subject.should_receive(:create_save_dialog).with(at.window("Save"), subject.wrapper).and_return(save_dialog_mock)
      save_dialog_mock.should_receive(:save).with("filename")
      
      should_do_until!(:not_exists, at.sheet(1)) {
        expect_click!(at.checkbox(1).window("Print"))
      }
      
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
      subject.wrapper.as_null_object
      subject.should_receive(:set_filename)
      subject.should_receive(:set_folder).with("/path/second")
      subject.save("/path/second/name")
    end
    
    it "Should be able to click save" do
      expect_click(at.button("Save").sheet(1))
      should_wait_until(:not_exists, at.sheet(1))
      subject.click_save
    end
    
    it "Should be able to set the filename" do
      subject.wrapper.should_receive(:set).with('value', at.text_field(1).sheet(1), "filename")
      subject.set_filename("filename")
    end
    
    it "Should be able to set the path" do
      expect_keystroke("g", [ :command, :shift ])
      should_wait_until(:exists,  at.sheet(1).sheet(1))
      subject.wrapper.should_receive(:set).with("value", at.text_field(1).sheet(1).sheet(1), "path")
      expect_click(at.button("Go").sheet(1).sheet(1))
      should_wait_until(:not_exists, at.sheet(1).sheet(1))
      subject.set_folder("path")
    end
  end
end