
require 'osaka'

describe "Wrapper around the defaults app which can be used for storing and retrieving preferences" do

  before (:each) do
    @worldclock_widget = <<-END_OF_DUMP
{
    "0000000000000002-city" = 44;
    "0000000000000002-continent" = 1;
    city = 44;
    continent = 1;
}
END_OF_DUMP
  end

  it "Can retrieve the settings from a domain (A domain is usually an application)" do
    expect(Osaka::CommandRunner).to receive(:run).with("defaults read widget-com.apple.widget.worldclock").and_return(@worldclock_widget)
    settings = DefaultsSystem.new("widget-com.apple.widget.worldclock")
    expect(settings["city"]).to eq "44"
  end

  it "Can set settings on a domain" do
    expect(Osaka::CommandRunner).to receive(:run).with("defaults read com.osaka").and_return(@worldclock_widget)
    expect(Osaka::CommandRunner).to receive(:run).with("defaults write com.osaka key value").and_return(@worldclock_widget)
    settings = DefaultsSystem.new("com.osaka")
    settings["key"] = "value"
  end

end
