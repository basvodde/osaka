
module Osaka
  module OsakaExpectations
        
    def simulate_mac_version(version)
      control.should_receive(:mac_version).and_return(version)
    end
        
    def expect_execute_osascript(command = nil)
      return Osaka::ScriptRunner.should_receive(:execute).with(command) unless command.nil?
      Osaka::ScriptRunner.should_receive(:execute)
    end
    
    def expect_clone
      control.should_receive(:clone)
    end
    
    def expect_activate
      control.should_receive(:activate)
    end

    def expect_launch
      control.should_receive(:launch)
    end
    
    def expect_focus
      control.should_receive(:focus)
    end

    def expect_focus!
      control.should_receive(:focus!)
    end
    
    def expect_set_current_window(name)
      control.should_receive(:set_current_window).with(name)
    end
    
    def expect_running?
      control.should_receive(:running?)
    end
    
    def expect_quit
      control.should_receive(:quit)
    end
    
    def expect_window_list
      control.should_receive(:window_list)
    end
    
    def expect_current_window_name
      control.should_receive(:current_window_name)
    end
    
    def expect_set(element, location, value)
      control.should_receive(:set).with(element, location, value)
    end

    def expect_set!(element, location, value)
      control.should_receive(:set!).with(element, location, value)
    end
    
    def expect_get_app!(element)
      control.should_receive(:get_app!).with(element)
    end
    
    def expect_keystroke(key, modifier = [])
      control.should_receive(:keystroke).with(key, modifier).and_return(control) unless modifier.empty?
      control.should_receive(:keystroke).with(key).and_return(control) if modifier.empty?
    end
    
    def expect_keystroke!(key, modifier = [])
      control.should_receive(:keystroke!).with(key, modifier).and_return(control) unless modifier.empty?
      control.should_receive(:keystroke!).with(key).and_return(control) if modifier.empty?
    end
    
    def expect_click!(location)
      control.should_receive(:click!).with(location).and_return(control)
    end
    
    def expect_click(location)
      control.should_receive(:click).with(location).and_return(control)
    end
    
    def expect_click_menu_bar(menu_item, menu_name)
      control.should_receive(:click_menu_bar).with(menu_item, menu_name).and_return(control)
    end
    
    def expect_get!(element, location)
      control.should_receive(:get!).with(element, location)
    end
    
    def expect_tell(do_this)
      control.should_receive(:tell).with(do_this)
    end
    
    def expect_system_event(event)
      control.should_receive(:system_event).with(event)
    end

    def expect_system_event!(event)
      control.should_receive(:system_event!).with(event)
    end
    
    def expect_exists?(location)
      control.should_receive(:exists?).with(location)
    end
    
    def expect_not_exists?(location)
      control.should_receive(:not_exists?).with(location)
    end
    
    def expect_wait_until_exists(*location)
      control.should_receive(:wait_until_exists).with(*location)
    end

    def expect_wait_until_exists!(*location)
      control.should_receive(:wait_until_exists!).with(*location)
    end
    
    def expect_wait_until_not_exists(location)
      control.should_receive(:wait_until_not_exists).with(location)
    end

    def expect_wait_until_not_exists!(location, action)
      control.should_receive(:wait_until_not_exists!).with(location)
    end
    
    def expect_until_not_exists!(element)
      control.should_receive(:until_not_exists!).with(element).and_yield
    end  
  end
end