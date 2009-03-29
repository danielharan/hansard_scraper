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
    anchor.gsub!(/^#/, '')
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
      if p.name == 'a' && p.attributes['name'].match(/Para.*/)
        p = p.next_sibling # following paragraph is actually what interests us
        paras << strip_inner(p)
      elsif p.inner_text.match(/^\[(.*)\]/) # procedural notes like [<i>Translation</i>]
        paras << "<div class='procedural'>#{p.inner_text}</div>"
      else
        break
      end
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
    links = []
    header1, header2, header3 = '', '', ''
    
    toc_elements.each do |toc_element|
      case toc_element.attributes["class"]
      when 'TocObTitle'
        header1, header2, header3 = inner_toc_link(toc_element) || '', '', ''
      when 'TocSbTitle'
        header2, header3 = inner_toc_link(toc_element), ''
      when 'toc_SOBQualifier'
        header3 = inner_toc_link(toc_element)
      when 'toc_Intervention'
        links << TocLink.new(header1, header2, header3, intervention_anchor(toc_element))
      end
    end
    
    links
  end
  
  def toc_elements
    ary = []
    toc_start = (@contents / "a[@href='#EndOfToc']").first
    toc_end   = (@contents / "a[@name='EndOfToc']").first
    
    Hpricot::Elements.expand(toc_start, toc_end).each do |toc_element|
      next if toc_element.is_a?(Hpricot::Text) ||  toc_element.name != "div"
      ary << toc_element
      ary += (toc_element / 'div') if toc_element.attributes['class'] == 'toc_level2'
    end
    
    ary
  end

  private
    def strip_inner(el)
      el.inner_text.strip.gsub(/^\?*/,'')
    end
    
    def inner_toc_link(e)
      matches = (e / "a[@class='tocLink']")
      matches.any? ? matches.inner_text.strip : nil
    end
    
    def intervention_anchor(source)
      (source / "a[@class='tocLink']").first.attributes["href"]
    end
end