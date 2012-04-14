
require 'osaka'

describe "Osaka::TypicalApplication" do

  include(*Osaka::ApplicationWrapperExpectations)
  
  subject { Osaka::TypicalApplication.new("ApplicationName") }
  
  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper")
  end
  
  it "Should pass the right open string to the Keynote application osascript" do
    filename = "filename.key"
    expect_tell("open \"#{File.absolute_path(filename)}\"")
    @wrapper.should_receive(:window=).with(filename)
    subject.open(filename)    
  end
  
  it "Should be able to quit" do
    @wrapper.should_receive(:quit)
    subject.quit
  end
  
  it "Should be able to quit without saving" do
    @wrapper.should_receive(:window).any_number_of_times.and_return("Untitled")
    @wrapper.should_receive(:quit)
    should_do_until!(:not_exists, "window \"Untitled\"") {
      should_check!(:exists, "sheet 1 of window \"Untitled\"", true)
      expect_click!('button 2 of sheet 1 of window "Untitled"')
    }
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
    subject.wrapper.should_receive(:window=).with("new_window")
    subject.wrapper.should_receive(:focus)
    subject.new_document
  end
  
  it "Should be able to save" do
    expect_keystroke("s", :command)
    subject.save
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
    
  it "Should be able to activate keynote" do
    @wrapper.should_receive(:activate)
    subject.activate
  end
  
  it "Should be able to retrieve a print dialog" do
    expect_keystroke("p", :command)
    @wrapper.should_receive(:construct_window_info).and_return(" of window 1")
    should_wait_until(:exists, "sheet 1 of window 1")
    subject.print_dialog
  end
  
  describe "Application info" do
    it "Should be able to retrieve an application info object and parse it" do
      @wrapper.should_receive(:tell).with('get info for (path to application "ApplicationName")').and_return('name:ApplicationName.app, creation date:date "Sunday, December 21, 2008 PM 06:14:11"}')
      app_info = subject.get_info
      app_info.name.should == "ApplicationName.app"
    end
  end
  
  describe "Generic Print Dialog" do
    
    location = "window 1"
    subject { Osaka::TypicalPrintDialog.new("window 1", double(:OSAApp).as_null_object) }

    it "Should be able to save the PDF in a print dialog" do
      save_dialog_mock = double(:GenericSaveDialog)
      
      expect_click!('menu button "PDF" of window 1') 
      should_wait_until!(:exists, 'menu 1 of menu button "PDF" of window 1')
      
      expect_click!('menu item 2 of menu 1 of menu button "PDF" of window 1')
      should_wait_until!(:exists, 'window "Save"')

      subject.should_receive(:create_save_dialog).with("window \"Save\"", subject.wrapper).and_return(save_dialog_mock)
      save_dialog_mock.should_receive(:save).with("filename")
      
      should_do_until!(:not_exists, 'window 1') {
        expect_click!('checkbox 1 of window "Print"')
      }
      
      subject.save_as_pdf("filename")
    end
  end
  
  describe "Generic Save Dialog" do
    
    subject { Osaka::TypicalSaveDialog.new("window 1", double("Osaka::ApplicationWrapper").as_null_object)}
    
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
      expect_click('button "Save" of window 1')
      should_wait_until(:not_exists, 'window 1')
      subject.click_save
    end
    
    it "Should be able to set the filename" do
      subject.wrapper.should_receive(:set).with('value', 'text field 1 of window 1', "filename")
      subject.set_filename("filename")
    end
    
    it "Should be able to set the path" do
      expect_keystroke("g", [ :command, :shift ])
      should_wait_until(:exists,  "sheet 1 of window 1")
      subject.wrapper.should_receive(:set).with("value", "text field 1 of sheet 1 of window 1", "path")
      expect_click('button "Go" of sheet 1 of window 1')
      should_wait_until(:not_exists, "sheet 1 of window 1")
      subject.set_folder("path")
    end
  end
end