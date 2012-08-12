
module Osaka
  module ApplicationWrapperExpectations
    
    def expect_clone
      wrapper.should_receive(:clone)
    end
    
    def expect_activate
      wrapper.should_receive(:activate)
    end
    
    def expect_focus
      wrapper.should_receive(:focus)
    end
    
    def expect_set_current_window(name)
      wrapper.should_receive(:set_current_window).with(name)
    end
    
    def expect_running?
      wrapper.should_receive(:running?)
    end
    
    def expect_quit
      wrapper.should_receive(:quit)
    end
    
    def expect_window_list
      wrapper.should_receive(:window_list)
    end
    
    def expect_set(element, location, value)
      wrapper.should_receive(:set).with(element, location, value)
    end
    
    def expect_keystroke(key, modifier = [])
      wrapper.should_receive(:keystroke).with(key, modifier).and_return(wrapper) unless modifier.empty?
      wrapper.should_receive(:keystroke).with(key).and_return(wrapper) if modifier.empty?
    end
    
    def expect_keystroke!(key, modifier = [])
      wrapper.should_receive(:keystroke!).with(key, modifier).and_return(wrapper) unless modifier.empty?
      wrapper.should_receive(:keystroke!).with(key).and_return(wrapper) if modifier.empty?
    end
    
    def expect_click!(location)
      wrapper.should_receive(:click!).with(location).and_return(wrapper)
    end
    
    def expect_click(location)
      wrapper.should_receive(:click).with(location).and_return(wrapper)
    end
    
    def expect_click_menu_bar(menu_item, menu_name)
      wrapper.should_receive(:click_menu_bar).with(menu_item, menu_name).and_return(wrapper)
    end
    
    def expect_get!(element, location)
      wrapper.should_receive(:get!).with(element, location)
    end
    
    def expect_tell(do_this)
      wrapper.should_receive(:tell).with(do_this)
    end
    
    def expect_system_event(event)
      wrapper.should_receive(:system_event).with(event)
    end
    
    def expect_exists(location)
      wrapper.should_receive(:exists).with(location)
    end
    
    def expect_wait_until_exists(location)
      wrapper.should_receive(:wait_until_exists).with(location)
    end

    def expect_wait_until_exists!(*location)
      wrapper.should_receive(:wait_until_exists!).with(*location)
    end
    
    def expect_wait_until_not_exists(location)
      wrapper.should_receive(:wait_until_not_exists).with(location)
    end
    
    def expect_until_not_exists!(element)
      wrapper.should_receive(:until_not_exists!).with(element).and_yield
    end  
  end
end