
require 'osaka'

describe "Osaka::Pages" do

  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::Pages.new }
  
  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
  end
  
  it "Should be able to do mail merge to a PDF flow" do
    
    mail_merge_dialog = double(:PagesMailMergeDialog)
    print_dialog = double(:GenericPrintDialog)
    
    subject.should_receive(:mail_merge).and_return(mail_merge_dialog)
    mail_merge_dialog.should_receive(:merge).and_return(print_dialog)
    print_dialog.should_receive(:save_as_pdf).with("filename")
    
    subject.mail_merge_to_pdf("filename")
  end
    
  it "Should be able to select the Mail Merge" do
    expect_system_event('tell menu bar 1; tell menu "Edit"; click menu item 20; end tell; end tell')
    should_wait_until(:exists, 'button "Merge" of sheet 1 of window 1')
    subject.mail_merge
  end

  it "Should click the merge button of the mail merge dialog" do
    expect_click!('button "Merge" of sheet 1 of window 1')
    should_wait_until!(:exists, 'menu button "PDF" of window "Print"')
    subject.mail_merge.merge
  end
  
  
end

describe "Osaka::Pages Mail Merge dialog" do
  
  include(*Osaka::ApplicationWrapperExpectations)

  subject { Osaka::PagesMailMergeDialog.new("", nil) }
  
  before (:each) do
    @wrapper = subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
    @location = subject.location = "window 1"
  end
  
  it "Should be able to set the mail merge dialog to merge to new document" do
    expect_click("pop up button 2 of #{@location}")
    should_wait_until!(:exists, "menu item 1 of menu 1 of pop up button 2 of #{@location}")
    expect_click!("menu item 1 of menu 1 of pop up button 2 of #{@location}")
    subject.set_merge_to_new_document
  end
  
  it "Should be able to set the mail merge dialog to merge to printer" do
    expect_click("pop up button 2 of #{@location}")
    should_wait_until!(:exists, "menu item 2 of menu 1 of pop up button 2 of #{@location}")
    expect_click!("menu item 2 of menu 1 of pop up button 2 of #{@location}")
    subject.set_merge_to_printer    
  end
end

