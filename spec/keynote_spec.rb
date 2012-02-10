
require 'osaka'

describe "Osaka::Keynote" do

  subject { Osaka::Keynote.new }
  
  before (:each) do
    subject.wrapper = double("Osaka::ApplicationWrapper").as_null_object
  end
end
