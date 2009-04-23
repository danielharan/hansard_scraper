require 'rubygems'
require 'hpricot'

%w{intervention toc_link division array_utils hpricot_extractor header}.each {|f| require File.join(File.dirname(__FILE__), f) }

class Extractor
  include HpricotExtractor
  attr_accessor :contents, :headers1
  def initialize(filename)
    @contents = Hpricot(IO.read(filename))
  end
  
  def extract_tree!
    @headers1  = []
    h1, h2, h3 = nil, nil, nil
    toc_element = nil
    
    toc_elements.each do |toc_element|
      case toc_element.attributes["class"]
      when 'TocObTitle'
        h1, h2, h3 = Header.new(inner_toc_link(toc_element) || ''), nil, nil
        @headers1 << h1
      when 'TocSbTitle'
        h2, h3 = Header.new(inner_toc_link(toc_element)), nil
        h1.sub_headers << h2
      when 'toc_SOBQualifier'
        h2 = empty_header_for(h1) if h2.nil?
        h3 = Header.new(inner_toc_link(toc_element))
        h2.sub_headers << h3
      when 'toc_Intervention'
        h2 = empty_header_for(h1) if h2.nil?
        h3 = empty_header_for(h2) if h3.nil?
        h3.interventions << intervention(intervention_anchor(toc_element))
      end
    end
    
    @headers1
    
  rescue NoMethodError => nme
    puts "h1, h2, h3: #{h1}, #{h2}, #{h3}"
    puts "toc_element: #{toc_element}"
    puts "got a NoMethodError: #{nme.inspect}"
  end
  
  def division(anchor)
    p = find_following(element_by_anchor(@contents, anchor), 'p')
    
    yeas, nays, paired = [0,1,2].collect do |i| 
      voters = ((p / "table//table")[i] / "font")[1..-1]
      voters.nil? ? [] : voters.collect {|e| e.inner_text}
    end
    
    Division.new(yeas, nays, paired)
  end
  
  def intervention(anchor)
    Intervention.new(@contents, anchor)
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
    def inner_toc_link(e)
      matches = (e / "a[@class='tocLink']")
      matches.any? ? matches.inner_text.strip : nil
    end
    
    def intervention_anchor(source)
      (source / "a[@class='tocLink']").first.attributes["href"]
    end
    
    def empty_header_for(parent)
      ret = Header.new('')
      parent.sub_headers << ret
      ret
    end
end