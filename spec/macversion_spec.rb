# encoding: utf-8
require 'osaka'

describe "Mac Version for writing cross-version code" do

  include(*Osaka::OsakaExpectations)

  subject { MacVersion.new }

  it "Can get the OS version (lion)" do
    expect_execute_osascript("system version of (system info)").and_return("10.7.4\n")
    expect(subject.version).to eq :lion
  end

  it "Can get the OS version (lion) string" do
    expect_execute_osascript("system version of (system info)").and_return("10.7.4\n")
    expect_execute_osascript("system version of (system info)").and_return("10.7.4\n")
    expect(subject.system_version).to eq "10.7.4"
  end

  it "Can get the OS version (mountain lion)" do
    expect_execute_osascript("system version of (system info)").and_return("10.8\n")
    expect(subject.version).to eq :mountain_lion
  end

  it "Can get the OS version (snow leopard)" do
    expect_execute_osascript("system version of (system info)").and_return("10.6\n")
    expect(subject.version).to eq :snow_leopard
  end

  it "Can get the OS version (el capitain)" do
    expect_execute_osascript("system version of (system info)").and_return("10.11\n")
    expect(subject.version).to eq :el_capitain
  end

  it "Can get the OS version (Sierra)" do
    expect_execute_osascript("system version of (system info)").and_return("10.12\n")
    expect(subject.version).to eq :sierra
  end

  it "Can get the OS version (other)" do
    expect_execute_osascript("system version of (system info)").and_return("1\n")
    expect(subject.version).to eq :other
  end

  it "OSVersion in before a certain version" do
    expect_execute_osascript("system version of (system info)").and_return("10.10\n")
    expect(subject.version_before(:el_capitain)).to eq true
  end

  it "OSVersion in before a certain version" do
    expect_execute_osascript("system version of (system info)").and_return("10.11\n")
    expect(subject.version_before(:el_capitain)).to eq false
  end

end
