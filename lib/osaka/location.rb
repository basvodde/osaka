
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
    
    def to_s
      @location_name
    end
    
    def as_prefixed_location
      return "" if to_s.empty?
      " of " + to_s
    end

    def button(name)
      create_location_with_added_name("button", name)
    end
    
    def group(name)
      create_location_with_added_name("group", name)
    end
    
    def window(name)
      create_location_with_added_name("window", name)
    end
    
    def has_window?
      as_prefixed_location.scan(" of window").length == 1
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
    
    def dialog(name)
      create_location_with_added_name("dialog", name)
    end
    
    def checkbox(name)
      create_location_with_added_name("checkbox", name)
    end
    
    def sheet(name)
      create_location_with_added_name("sheet", name)
    end
    
    def to_location_string(name)
      return name.to_s if name.kind_of? Integer
      '"' + name.to_s + '"'
    end
    
    def create_location_with_added_name(element, name)
      self + Location.new(element + " " + to_location_string(name))
    end
    
    def ==(obj)
      @location_name == obj.to_s
    end
      
  end
  
end

def at
  Osaka::Location.new ""
end