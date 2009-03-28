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
    intervention.paragraphs = [extract_first_paragraph(p), *extract_following_paragraphs(p) ]
    
    intervention
  end
  
  def extract_first_paragraph(p)
    (p / "div/div").remove
    strip_inner(p)
  end
  
  def extract_following_paragraphs(p)
    paras = []
    while (p = p.next_sibling.next_sibling) do
      break unless p.name == 'p'
      paras << strip_inner(p)
    end
    paras
  end
  
  def find_following(element, element_type)
    10.times do
      element = element.next_sibling
      return element if element.name == element_type.to_s
    end
    raise "oops"
  end
  
  private
    def strip_inner(el)
      el.inner_text.strip.gsub(/^\?*/,'')
    end
end