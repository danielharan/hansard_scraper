require 'rubygems'
require 'hpricot'
require File.join(File.dirname(__FILE__), 'intervention')

class Extractor
  attr_accessor :contents
  def initialize(filename)
    @contents = Hpricot(IO.read(filename))
  end
  
  def intervention(anchor)
    intervention = Intervention.new
    element = (@contents / "a[@name='#{anchor}']").first
    
    p = find_following(element, :p)
    
    intervention.link = (p / "//a[@class='WebOption'").first.attributes["href"]
    
    intervention
  end
  
  def find_following(element, element_type)
    10.times do
      element = element.next_sibling
      puts element.inspect
      return element if element.name == element_type.to_s
    end
    raise "oops"
  end
end