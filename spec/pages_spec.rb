
require 'osaka'

describe "Osaka::Pages" do

  include(*Osaka::OsakaExpectations)

  subject { Osaka::Pages.new }
  
  let (:control) { subject.control = mock("Remote Control", :name => "ApplicationName")}
  
  context "Basic document operations" do
    
    it "Should be able to type in the file" do
      expect_keystroke("Hello")
      subject.type("Hello")
    end
    
  end
  
  it "Should be able to do mail merge to a PDF flow" do
    
    mail_merge_dialog = mock("Pages Mail Merge Dialog")
    print_dialog = mock("Generic Print Dialog")
    
    subject.should_receive(:mail_merge).and_return(mail_merge_dialog)
    mail_merge_dialog.should_receive(:merge).and_return(print_dialog)
    mail_merge_dialog.should_receive(:set_merge_to_printer)
    print_dialog.should_receive(:save_as_pdf).with("filename")
    
    subject.mail_merge_to_pdf("filename")
  end
    
  it "Should be able to select the Mail Merge" do
    expect_current_window_name.any_number_of_times.and_return("Pages.pages")
    expect_click_menu_bar(at.menu_item(20), "Edit")
    expect_wait_until_exists(at.button("Merge").sheet(1))
    subject.mail_merge
  end

  it "Should click the merge button of the mail merge dialog" do
    expect_current_window_name.any_number_of_times.and_return("Pages.pages")

    expect_click_menu_bar(at.menu_item(20), "Edit")
    expect_wait_until_exists(at.button("Merge").sheet(1))

    expect_click!(at.button("Merge").sheet(1))
    expect_wait_until_exists!(at.menu_button("PDF").window("Print"))
    subject.mail_merge.merge
  end
  
  it "Should be able to get an inspector object" do
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("Link")
    expect_exists?(at.menu_item("Show Inspector").menu(1).menu_bar_item("View").menu_bar(1)).and_return(true)
    expect_click_menu_bar(at.menu_item("Show Inspector"), "View")
    
    inspector_mock = mock("Inspector")
    Osaka::PagesInspector.should_receive(:new).with(control.name, at.window("Link")).and_return(inspector_mock)    
    subject.inspector.should equal(inspector_mock)
  end
  
  it "Should be able to get the inspector object also when it is already visible" do
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("Link")
    expect_exists?(at.menu_item("Show Inspector").menu(1).menu_bar_item("View").menu_bar(1)).and_return(false)
    expect_click_menu_bar(at.menu_item("Hide Inspector"), "View")
    expect_wait_until_exists(at.menu_item("Show Inspector").menu(1).menu_bar_item("View").menu_bar(1))
    expect_click_menu_bar(at.menu_item("Show Inspector"), "View")
    subject.inspector
  end
  
  it "Should be able to change the mail merge document source" do
    inspector_mock = mock("Inspector")
    subject.should_receive(:inspector).and_return(inspector_mock)
    inspector_mock.should_receive(:change_mail_merge_source)
    
    expect_wait_until_exists(at.sheet(1))
    subject.should_receive(:do_and_wait_for_new_window).and_yield.and_return("dialog")
    expect_click(at.radio_button("Numbers Document:").radio_group(1).sheet(1))
    
    dialog_mock = mock("Open Dialog")
    subject.should_receive(:create_dialog).with(Osaka::TypicalOpenDialog, at.window("dialog")).and_return(dialog_mock)
    dialog_mock.should_receive(:set_folder).with("/tmp")
    dialog_mock.should_receive(:select_file).with("filename")
    
    
    subject.set_mail_merge_document("/tmp/filename")    
  end
  
end

describe "Osaka::Pages Inspector" do
  
  include(*Osaka::OsakaExpectations)

  subject {Osaka::PagesInspector.new("Pages", "Link")}
  let(:control) {subject.control = mock("RemoteControl")}
  
  it "Can convert symbolic names to locations" do
    # Nice... checking a map. Perhaps delete ?
    subject.get_location_from_symbol(:document).should == at.radio_button(1).radio_group(1)
    subject.get_location_from_symbol(:layout).should == at.radio_button(2).radio_group(1)
    subject.get_location_from_symbol(:wrap).should == at.radio_button(3).radio_group(1)
    subject.get_location_from_symbol(:text).should == at.radio_button(4).radio_group(1)
    subject.get_location_from_symbol(:graphic).should == at.radio_button(5).radio_group(1)
    subject.get_location_from_symbol(:metrics).should == at.radio_button(6).radio_group(1)
    subject.get_location_from_symbol(:table).should == at.radio_button(7).radio_group(1)
    subject.get_location_from_symbol(:chart).should == at.radio_button(8).radio_group(1)
    subject.get_location_from_symbol(:link).should == at.radio_button(9).radio_group(1)
    subject.get_location_from_symbol(:quicktime).should == at.radio_button(10).radio_group(1)
  end
  
  
  it "Should be able to select the different inspectors" do
    expect_click(subject.get_location_from_symbol(:document))
    expect_wait_until_exists(at.window("document"))
    expect_set_current_window("document")
    subject.select_inspector(:document)
  end
  
  it "Change the mail merge source" do
    subject.should_receive(:select_inspector).with(:link)
    expect_click(at.button("Choose...").tab_group(1).group(1))
    subject.change_mail_merge_source
  end

end

describe "Osaka::Pages Mail Merge dialog" do
  
  include(*Osaka::OsakaExpectations)

  subject { Osaka::PagesMailMergeDialog.new("", nil) }
  let(:control) {subject.control = mock("RemoteControl").as_null_object}
  
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

