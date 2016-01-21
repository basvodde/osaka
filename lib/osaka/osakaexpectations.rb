
module Osaka
  module OsakaExpectations

    def simulate_mac_version(version)
      expect(control).to receive(:mac_version).and_return(version)
    end

    def expect_execute_osascript(command = nil)
      return expect(Osaka::ScriptRunner).to receive(:execute).with(command) unless command.nil?
      expect(Osaka::ScriptRunner).to receive(:execute)
    end

    def expect_clone
      expect(control).to receive(:clone)
    end

    def expect_activate
      expect(control).to receive(:activate)
    end

    def expect_launch
      expect(control).to receive(:launch)
    end

    def expect_focus
      expect(control).to receive(:focus)
    end

    def expect_focus!
      expect(control).to receive(:focus!)
    end

    def expect_set_current_window(name)
      expect(control).to receive(:set_current_window).with(name)
    end

    def expect_running?
      expect(control).to receive(:running?)
    end

    def expect_quit
      expect(control).to receive(:quit)
    end

    def expect_window_list
      expect(control).to receive(:window_list)
    end

    def expect_standard_window_list
      expect(control).to receive(:standard_window_list)
    end

    def expect_current_window_name
      expect(control).to receive(:current_window_name)
    end

    def expect_set(element, location, value)
      expect(control).to receive(:set).with(element, location, value)
    end

    def expect_set!(element, location, value)
      expect(control).to receive(:set!).with(element, location, value)
    end

    def expect_get_app!(element)
      expect(control).to receive(:get_app!).with(element)
    end

    def expect_keystroke(key, modifier = [])
      expect(control).to receive(:keystroke).with(key, modifier).and_return(control) unless modifier.empty?
      expect(control).to receive(:keystroke).with(key).and_return(control) if modifier.empty?
    end

    def expect_keystroke!(key, modifier = [])
      expect(control).to receive(:keystroke!).with(key, modifier).and_return(control) unless modifier.empty?
      expect(control).to receive(:keystroke!).with(key).and_return(control) if modifier.empty?
    end

    def expect_click!(location)
      expect(control).to receive(:click!).with(location).and_return(control)
    end

    def expect_click(location)
      expect(control).to receive(:click).with(location).and_return(control)
    end

    def expect_click_menu_bar(menu_item, menu_name)
      expect(control).to receive(:click_menu_bar).with(menu_item, menu_name).and_return(control)
    end

    def expect_get!(element, location)
      expect(control).to receive(:get!).with(element, location)
    end

    def expect_tell(do_this)
      expect(control).to receive(:tell).with(do_this)
    end

    def expect_system_event(event)
      expect(control).to receive(:system_event).with(event)
    end

    def expect_system_event!(event)
      expect(control).to receive(:system_event!).with(event)
    end

    def expect_exists?(location)
      expect(control).to receive(:exists?).with(location)
    end

    def expect_not_exists?(location)
      expect(control).to receive(:not_exists?).with(location)
    end

    def expect_wait_until_exists(*location)
      expect(control).to receive(:wait_until_exists).with(*location)
    end

    def expect_wait_until_exists!(*location)
      expect(control).to receive(:wait_until_exists!).with(*location)
    end

    def expect_wait_until_not_exists(location)
      expect(control).to receive(:wait_until_not_exists).with(location)
    end

    def expect_wait_until_not_exists!(location, action)
      expect(control).to receive(:wait_until_not_exists!).with(location)
    end

    def expect_until_not_exists!(element)
      expect(control).to receive(:until_not_exists!).with(element).and_yield
    end

    def expect_mac_version_before(version_name)
      expect(control).to receive(:mac_version_before).with(version_name)
    end
  end
end
