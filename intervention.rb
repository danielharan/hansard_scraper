%w{hpricot_extractor}.each {|f| require File.join(File.dirname(__FILE__), f) }

class Intervention
  include HpricotExtractor
  attr_accessor :name, :link, :paragraphs
  
  def initialize(hansard, anchor)
    p = find_following(element_by_anchor(hansard, anchor), :p)

    top_link          = (p / "//a[@class='WebOption'").first
    @link = top_link.attributes["href"]
    @name = top_link.inner_text
    @paragraphs = [extract_first_paragraph(p), *extract_following_paragraphs(p) ]
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
      elsif p.name == 'a' && p.attributes['name'].match(/^PT/)
        p = p.next_sibling
        paras << "<div class='procedural_text'>#{strip_inner(p)}</div>"
      elsif p.inner_text.match(/^\[(.*)\]/) # procedural notes like [<i>Translation</i>]
        paras << "<div class='procedural'>#{p.inner_text}</div>"
      elsif p.name == 'a' && p.attributes['name'].match(/^T(.*)/)
        p = p.next_sibling # discard nav; we're only interested in the timestamp
        paras << "<div class='timestamp'>(#{$1})</div>"
      elsif p.name == 'p' && p.next_sibling.attributes['name'] && p.next_sibling.attributes['name'].match(/^T(.*)/)
        # sometimes the timestamp is after the divider, just before the next heading :S
        paras << "<div class='timestamp'>(#{$1})</div>"
        break
      else
        break
      end
    end
    paras
  end
  
  private
    def strip_inner(el)
      el.inner_text.strip.gsub(/^\?*/,'').strip
    end
end