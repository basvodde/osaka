# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalPrintDialog" do

  include(*Osaka::OsakaExpectations)
  subject { Osaka::TypicalPrintDialog.new(at.sheet(1), double(:OSAApp).as_null_object) }
    
  let(:control) { subject.control = double("Osaka::RemoteControl") }

  it "Should be able to save the PDF in a print dialog" do
    save_dialog_mock = double(:GenericSaveDialog)
    
    expect_click!(at.menu_button("PDF").sheet(1)) 
    expect_wait_until_exists!(at.menu(1).menu_button("PDF").sheet(1))
    
    expect_click!(at.menu_item(2).menu(1).menu_button("PDF").sheet(1))
    expect_wait_until_exists!(at.window("Save"), at.sheet(1).window("Print")).and_return(at.window("Save"))

    subject.should_receive(:create_save_dialog).with(at.window("Save"), subject.control).and_return(save_dialog_mock)
    save_dialog_mock.should_receive(:save).with("filename")
    
    expect_until_not_exists!(at.sheet(1))
    expect_exists(at.checkbox(1).sheet(1)).and_return(true)
    expect_click!(at.checkbox(1).sheet(1))
    
    subject.save_as_pdf("filename")
  end

end
