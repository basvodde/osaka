# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalSaveDialog" do

  include(*Osaka::OsakaExpectations)
  subject { Osaka::TypicalSaveDialog.new("Application", at.sheet(1))}
  let(:control) { subject.control = double("RemoteControl", :base_location => at.sheet(1)) }
  
  it "Should set the filename in the test field" do
    expect(subject).to receive(:set_filename).with("filename")
    expect(subject).to receive(:click_save)
    subject.save("filename")
  end
  
  it "Should pick only the base filename when a path is given" do
    expect(subject).to receive(:set_filename).with("filename")
    expect(subject).to receive(:set_folder)
    expect(subject).to receive(:click_save)
    subject.save("/path/filename")
  end
  
  it "Should set the path when a full path is given" do
    control.as_null_object
    expect(subject).to receive(:set_filename)
    expect(subject).to receive(:set_folder).with("/path/second")
    subject.save("/path/second/name")
  end
  
  it "Should be able to click save" do
    expect_click(at.button("Save"))
    expect_wait_until_not_exists(at.sheet(1))
    subject.click_save
  end
  
  it "Should be able to set the filename" do
    expect(control).to receive(:set).with('value', at.text_field(1), "filename")
    subject.set_filename("filename")
  end
  

end
