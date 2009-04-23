module HpricotExtractor
  def element_by_anchor(contents, anchor)
    anchor.gsub!(/^#/, '')
    (contents / "a[@name='#{anchor}']").first
  end
  
  def find_following(element, element_type)
    10.times do
      element = element.next_sibling
      return element if element.name == element_type.to_s
    end
    raise "oops"
  end
end