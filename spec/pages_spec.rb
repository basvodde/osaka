
require 'osaka'

describe "Osaka::Pages" do

  subject { Osaka::Pages.new }
  
  before (:each) do
    subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
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
    subject.wrapper.should_receive(:systemEvent).with("tell menu bar 1; tell menu \"Edit\"; click menu item 20; end tell; end tell")
    subject.wrapper.should_receive(:wait_until_exists).with('button "Merge" of sheet 1 of window 1')
    subject.mail_merge
  end

  it "Should click the merge button of the mail merge dialog" do
    subject.wrapper.should_receive(:click!).with('button "Merge" of sheet 1 of window 1')
    subject.wrapper.should_receive(:wait_until_exists!).with('menu button "PDF" of window "Print"')
    subject.mail_merge.merge
  end
  
end
