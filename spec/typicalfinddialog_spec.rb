# encoding: utf-8
require 'osaka'

describe "Osaka::TypicalFindDialog" do
  
  include(*Osaka::OsakaExpectations)
  subject { Osaka::TypicalFindDialog.new("Application", at.window(1))}
  let(:control) { subject.control = double("RemoteControl", :base_location => at.window(1)) }
  
  it "Should be able to populate the dialog" do
    expect(subject).to receive(:string_to_find).with "string"
    expect(subject).to receive(:string_replacement).with "replacement"
    expect(subject).to receive(:wait_for_replace_all_button?).and_return(true)
    expect(subject).to receive(:click_replace_all)
    expect(subject).to receive :close
    subject.find_replace_all("string", "replacement")
  end

end
