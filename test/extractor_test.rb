require 'test_helper'
require '../extractor'
require 'hpricot'

class ExtractorTest < Test::Unit::TestCase
  def setup
    @extractor = Extractor.new('../hansards/2009-03-12.html')
  end
  
  def test_extract_initialize
    assert_not_nil @extractor.contents
    assert @extractor.contents.is_a?(Hpricot::Doc)
  end
  
  def test_intervention
    intervention = @extractor.intervention('#Int-2655693')
    assert_not_nil intervention
    expected_link = "/HousePublications/GetWebOptionsCallBack.aspx?SourceSystem=PRISM&ResourceType=Affiliation&ResourceID=128173&language=1&DisplayMode=2"
    assert_equal expected_link, intervention.link
    assert_equal 2, intervention.paragraphs.length
    
    first = "Mr. Speaker, I cannot appeal your ruling, nor do I wish to, but I did ask for corrective action. With all due respect, it seems to me that you have not made it clear enough whether you want the minister to withdraw her offensive statements."
    second = "You have distinguished between remarks directed to an individual and remarks directed to a party. Depending on your response, and with your permission, I might have a statement to make, but we do not understand what sanction, if any, you have imposed by your ruling."
    
    assert_equal first, intervention.paragraphs.first
    assert_equal second, intervention.paragraphs.last
  end
  
  def test_intervention_with_multiple_paragraphs
    intervention = @extractor.intervention('#Int-2655773')
    assert_not_nil intervention
    assert_equal 4, intervention.paragraphs.length
  end
  
  def test_extract_toc
    toc = @extractor.toc
        
    assert_equal "#Int-2655585", toc.first.anchor
    assert_equal "Oral Questions--Speaker's Ruling", toc.first.header3
    assert_equal "Points of Order", toc.first.header2
    assert_equal "", toc.first.header1
    
    assert_equal "#Int-2660566", toc.last.anchor
    
    assert_equal 331, toc.length
  end
  
  def test_elements_between
    elems = @extractor.toc_elements
    assert_equal 331, elems.select {|e| e.name == 'div' && e.attributes['class'] == 'toc_Intervention'}.length
  end
end