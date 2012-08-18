
require 'osaka'

describe "Osaka::Pages" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Pages.new }
  
  let (:wrapper) { subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object}
  
  it "Should be able to do mail merge to a PDF flow" do
    
    mail_merge_dialog = double(:PagesMailMergeDialog)
    print_dialog = double(:GenericPrintDialog)
    
    subject.should_receive(:mail_merge).and_return(mail_merge_dialog)
    mail_merge_dialog.should_receive(:merge).and_return(print_dialog)
    mail_merge_dialog.should_receive(:set_merge_to_printer)
    print_dialog.should_receive(:save_as_pdf).with("filename")
    
    subject.mail_merge_to_pdf("filename")
  end
    
  it "Should be able to select the Mail Merge" do
    wrapper.should_receive(:current_window_name).any_number_of_times.and_return("Pages.pages")
    expect_click_menu_bar(at.menu_item(20), "Edit")
    expect_wait_until_exists(at.button("Merge").sheet(1))
    subject.mail_merge
  end

  it "Should click the merge button of the mail merge dialog" do
    wrapper.should_receive(:current_window_name).any_number_of_times.and_return("Pages.pages")
    expect_click!(at.button("Merge").sheet(1))
    expect_wait_until_exists!(at.menu_button("PDF").window("Print"))
    subject.mail_merge.merge
  end
end

describe "Osaka::Pages Mail Merge dialog" do
  
  include(*Osaka::OsakaExpectations)

  subject { Osaka::PagesMailMergeDialog.new("", nil) }
  let(:wrapper) {subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object}
  
  it "Should be able to set the mail merge dialog to merge to new document" do
    expect_click(at.pop_up_button(2).sheet(1))
    expect_wait_until_exists!(at.menu_item(1).menu(1).pop_up_button(2).sheet(1))
    expect_click!(at.menu_item(1).menu(1).pop_up_button(2).sheet(1))
    subject.set_merge_to_new_document
  end
  
  it "Should be able to set the mail merge dialog to merge to printer" do
    expect_click(at.pop_up_button(2).sheet(1))
    expect_wait_until_exists!(at.menu_item(2).menu(1).pop_up_button(2).sheet(1))
    expect_click!(at.menu_item(2).menu(1).pop_up_button(2).sheet(1))
    subject.set_merge_to_printer    
  end
end

