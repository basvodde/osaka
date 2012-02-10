
require 'osaka'

describe "Osaka::TypicalApplication" do

  subject { Osaka::TypicalApplication.new("ApplicationName") }
  
  before (:each) do
    subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
  end
  
  it "Should pass the right open string to the Keynote application osascript" do
    filename = "filename.key"
    subject.wrapper.should_receive(:tell).with("open \"#{File.absolute_path(filename)}\"")
    subject.open(filename)    
  end
  
  it "Should be able to quit" do
    subject.wrapper.should_receive(:quit)
    subject.quit
  end
  
  it "Should be able to save" do
    subject.wrapper.should_receive(:keystroke).with("s", :command)
    subject.save
  end
  
  it "Should be able to activate keynote" do
    subject.wrapper.should_receive(:activate)
    subject.activate
  end
  
  it "Should be able to retrieve a print dialog" do
    subject.wrapper.should_receive(:keystroke_and_wait_until_exists).with("p", :command, "sheet 1 of window 1")
    subject.print_dialog
  end
  
  describe "Generic Print Dialog" do
    
    location = "window 1"
    subject { Osaka::TypicalPrintDialog.new("window 1", double(:OSAApp).as_null_object) }

    it "Should be able to save the PDF in a print dialog" do
      save_dialog_mock = double(:GenericSaveDialog)
      subject.wrapper.should_receive(:click_and_wait_until_exists!).with('menu button "PDF" of window 1', 'menu 1 of menu button "PDF" of window 1')
      subject.wrapper.should_receive(:click_and_wait_until_exists!).with('menu item 2 of menu 1 of menu button "PDF" of window 1', 'window "Save"')
      subject.should_receive(:create_save_dialog).with("window \"Save\"", subject.wrapper).and_return(save_dialog_mock)
      save_dialog_mock.should_receive(:save).with("filename")
      subject.wrapper.should_receive(:wait_until_not_exists).with('window 1')
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
      subject.should_receive(:set_filename)
      subject.should_receive(:set_folder).with("/path/second")
      subject.save("/path/second/name")
    end
    
    it "Should be able to click save" do
      subject.wrapper.should_receive(:click_and_wait_until_not_exists).with('button "Save"  of window 1', 'window 1')
      subject.click_save
    end
    
    it "Should be able to set the filename" do
      subject.wrapper.should_receive(:set).with('value of text field 1 of window 1', "filename")
      subject.set_filename("filename")
    end
    
    it "Should be able to set the path" do
      subject.wrapper.should_receive(:keystroke_and_wait_until_exists).with("g", [ :command, :shift ], "sheet 1 of window 1")
      subject.wrapper.should_receive(:set).with("value of text field 1 of sheet 1 of window 1", "path")
      subject.wrapper.should_receive(:click_and_wait_until_not_exists).with('button "Go" of sheet 1 of window 1', "sheet 1 of window 1")
      subject.set_folder("path")
    end
  end
end