
module Osaka
  module ApplicationWrapperExpectations

    def should_wait(wait_command, wait_condition, wait_element)
      condition = double(:Condition)
      @wrapper.should_receive(wait_command).and_return(condition)
      condition.should_receive(wait_condition).with(wait_element)
    end

    def should_wait_until(wait_condition, wait_element)
      should_wait(:wait_until, wait_condition, wait_element)
    end

    def should_wait_until!(wait_condition, wait_element)
      should_wait(:wait_until!, wait_condition, wait_element)
    end

    def expect_keystroke(key, modifier)
      @wrapper.should_receive(:keystroke).with(key, modifier).and_return(@wrapper)
    end

    def expect_click!(location)
      @wrapper.should_receive(:click!).with(location).and_return(@wrapper)
    end

    def expect_click(location)
      @wrapper.should_receive(:click).with(location).and_return(@wrapper)
    end
  end
end