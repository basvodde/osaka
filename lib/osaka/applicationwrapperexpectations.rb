
module Osaka
  module ApplicationWrapperExpectations

    def should_wait_until(wait_condition, wait_element)
      should_do_with_condition(:wait_until, wait_condition, wait_element)
    end
    
    def should_wait_until!(wait_condition, wait_element)
      should_do_with_condition(:wait_until!, wait_condition, wait_element)
    end
    
    def should_check!(condition, element, return_value)
      should_do_with_condition(:check!, condition, element).and_return(return_value)
    end
    
    def should_do_until!(condition, element)
      should_do_with_condition(:until!, condition, element).and_yield
      yield
    end
    
    def expect_keystroke(key, modifier = [])
      @wrapper.should_receive(:keystroke).with(key, modifier).and_return(@wrapper) unless modifier.empty?
      @wrapper.should_receive(:keystroke).with(key).and_return(@wrapper) if modifier.empty?
    end
    
    def expect_keystroke!(key)
      @wrapper.should_receive(:keystroke!).with(key).and_return(@wrapper)
    end
    
    def expect_click!(location)
      @wrapper.should_receive(:click!).with(location).and_return(@wrapper)
    end
    
    def expect_click(location)
      @wrapper.should_receive(:click).with(location).and_return(@wrapper)
    end
    
    def expect_tell(do_this)
      @wrapper.should_receive(:tell).with(do_this)
    end
    
    def expect_system_event(event)
      @wrapper.should_receive(:system_event).with(event)
    end

private
    def should_do_with_condition(command, condition, element)
      condition_proxy = double(:ConditionAndActionProxy)
      @wrapper.should_receive(command).and_return(condition_proxy)
      condition_proxy.should_receive(condition).with(element)
    end
  
    
  end
end