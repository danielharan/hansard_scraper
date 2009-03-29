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
    header1   = ''
    toc_links = []
    toc_start = (@contents / "a[@href='#EndOfToc']").first
    toc_end   = (@contents / "a[@name='EndOfToc']").first
    
    Hpricot::Elements.expand(toc_start, toc_end).each do |toc_element|
      next if toc_element.is_a?(Hpricot::Text) ||  toc_element.name != "div"
      
      case toc_element.attributes["class"]
      when 'TocObTitle'
        header1 = inner_toc_link(toc_element) || ''
      when 'toc_level2'
        toc_links << extract_toc_level2(header1, toc_element)
      else
        #puts "NEXT!"
        next
      end
    end
    toc_links.flatten
  end
  
  private
    def strip_inner(el)
      el.inner_text.strip.gsub(/^\?*/,'')
    end
    
    def inner_toc_link(e)
      matches = (e / "a[@class='tocLink']")
      matches.any? ? matches.inner_text.strip : nil
    end
    
    def extract_toc_level2(header1, element)
      # FIXME: this is fugly and could break if they mix interventions under level2 and level
      (element / "//div[@class='toc_level3']").length > 0 ? extract_toc_level2_containing_level3s(header1, element) : 
                                                            extract_toc_level2_with_no_level3s(header1, element)
    end
    
    def extract_toc_level2_with_no_level3s(header1, element)
      links = []
      header2, header3 = '', ''
      (element / "div").each do |e|
        case e.attributes["class"]
        when 'TocSbTitle'
          header2 = inner_toc_link(e)
        when 'toc_Intervention'
          links << TocLink.new(header1, header2, '', intervention_anchor(e))
        end
      end
      links
    end
    
    def extract_toc_level2_containing_level3s(header1, element)
      links = []
      header2, header3 = '', ''
      (element / "div").each do |e|
        case e.attributes["class"]
        when 'TocSbTitle'
          header2 = inner_toc_link(e)
        when 'toc_level3'
          (e / "div").each do |el|
            case el.attributes["class"]
            when 'toc_SOBQualifier'
              header3 = inner_toc_link(el)
            when 'toc_Intervention'
              links << TocLink.new(header1, header2, header3, intervention_anchor(el))
            end
          end
        end
      end
      links
    end
    
    def intervention_anchor(source)
      (source / "a[@class='tocLink']").first.attributes["href"]
    end
end