
module Osaka
  class Location

    def initialize(location_name)
      @location_name = location_name.to_s
      validate
    end
    
    def validate
      raise(Osaka::InvalidLocation, "Invalid location: #{to_s}") if as_prefixed_location.scan(" of window").length > 1
    end
    
    def+(other_location)
      return Location.new(self) if other_location.to_s.empty?
      return Location.new(other_location) if to_s.empty?
      Location.new(to_s + " of " + other_location.to_s)
    end
    
    def top_level_element
      Location.new(@location_name[/window (.*)$/])
    end
    
    def to_s
      @location_name
    end
    
    def as_prefixed_location
      return "" if to_s.empty?
      " of " + to_s
    end
    
    def has_top_level_element?
      has_window? || has_menu_bar?
    end

    def button(name)
      create_location_with_added_name("button", name)
    end
    
    def group(name)
      create_location_with_added_name("group", name)
    end
    
    def tab_group(name)
      create_location_with_added_name("tab group", name)
    end
    
    def window(name)
      create_location_with_added_name("window", name)
    end
    
    def has_window?
      has_element?("window")
    end
    
    def static_text(name)
      create_location_with_added_name("static text", name)
    end
    
    def menu_button(name)
      create_location_with_added_name("menu button", name)
    end

    def menu(name)
      create_location_with_added_name("menu", name)
    end

    def menu_item(name)
      create_location_with_added_name("menu item", name)
    end

    def menu_bar(name)
      create_location_with_added_name("menu bar", name)
    end
    
    def has_menu_bar?
      has_element?("menu bar")
    end
    
    def menu_bar_item(name)
      create_location_with_added_name("menu bar item", name)
    end
    
    def dialog(name)
      create_location_with_added_name("dialog", name)
    end
    
    def checkbox(name)
      create_location_with_added_name("checkbox", name)
    end
    
    def sheet(name)
      create_location_with_added_name("sheet", name)
    end
    
    def text_field(name)
      create_location_with_added_name("text field", name)
    end

    def pop_up_button(name)
      create_location_with_added_name("pop up button", name)
    end
    
    def splitter_group(name)
      create_location_with_added_name("splitter group", name)
    end

    def scroll_area(name)
      create_location_with_added_name("scroll area", name)
    end
    
    def outline(name)
      create_location_with_added_name("outline", name)
    end
    
    def ui_element(name)
        create_location_with_added_name("UI element", name)
    end

    def row(name)
        create_location_with_added_name("row", name)
    end
    
    def radio_group(name)
      create_location_with_added_name("radio group", name)
    end

    def radio_button(name)
      create_location_with_added_name("radio button", name)
    end
    
    def to_location_string(name)
      return name.to_s if name.kind_of? Integer
      '"' + name.to_s + '"'
    end
    
    def create_location_with_added_name(element, name)
      self + Location.new(element + " " + to_location_string(name))
    end
    
    def has_element?(name)
      as_prefixed_location.scan(" of #{name}").length >= 1
    end
    
    def ==(obj)
      @location_name == obj.to_s
    end
      
  end
  
end

def at
  Osaka::Location.new ""
end
