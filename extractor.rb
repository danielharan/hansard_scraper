require 'rubygems'
require 'hpricot'

require File.join(File.dirname(__FILE__), 'intervention')
require File.join(File.dirname(__FILE__), 'toc_link')

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
    while (p = p.next_sibling) do
      break unless p.name == 'a' && p.attributes['name'].match(/Para.*/)
      p = p.next_sibling
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
  
  def toc
    toc_links = []
    toc_start = (@contents / "a[@href='#EndOfToc']").first
    toc_end   = (@contents / "a[@name='EndOfToc']").first
    
    header1, header2, header3 = '', '', ''
    Hpricot::Elements.expand(toc_start, toc_end).each do |toc_element|
      next if toc_element.is_a?(Hpricot::Text) ||  toc_element.name != "div"
      
      case toc_element.attributes["class"]
      when 'TocObTitle'
        header1 = toc_element.inner_text
      when 'TocSbTitle'
        header2 = inner_toc_link(toc_element)
      when 'toc_SOBQualifier'
        header3 = inner_toc_link(toc_element)
      when 'toc_Intervention'
        anchor = inner_toc_link(toc_element)
      else
        next
      end
      
      toc_links << TocLink.new(header1, header2, header3, anchor)
    end
  end
  
  private
    def strip_inner(el)
      el.inner_text.strip.gsub(/^\?*/,'')
    end
    
    def inner_toc_link(e)
      (e / "a[@class='tocLink']").first.inner_text
    end
end