require 'test_helper'
%w{extractor intervention}.each {|f| require File.join(File.dirname(__FILE__), '..', f) }


class InterventionTest < Test::Unit::TestCase
  def setup
    @hansard = Extractor.new(File.join(File.dirname(__FILE__), '..', '/hansards/2009-03-12.html')).contents
  end
  
  def test_initialize
    assert_not_nil Intervention.new(@hansard, '#Int-2655693')
  end
  
  def test_intervention
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2655693')
    
    expected_link = "/HousePublications/GetWebOptionsCallBack.aspx?SourceSystem=PRISM&ResourceType=Affiliation&ResourceID=128173&language=1&DisplayMode=2"
    assert_equal expected_link, intervention.link
    assert_equal "Mr. Michel Guimond (Montmorency—Charlevoix—Haute-Côte-Nord, BQ)", intervention.name
    assert_equal 2, intervention.paragraphs.length
    
    first = "Mr. Speaker, I cannot appeal your ruling, nor do I wish to, but I did ask for corrective action. With all due respect, it seems to me that you have not made it clear enough whether you want the minister to withdraw her offensive statements."
    second = "You have distinguished between remarks directed to an individual and remarks directed to a party. Depending on your response, and with your permission, I might have a statement to make, but we do not understand what sanction, if any, you have imposed by your ruling."
    
    assert_equal first, intervention.paragraphs.first
    assert_equal second, intervention.paragraphs.last
  end
  
  def test_intervention_with_multiple_paragraphs
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2655773')
    assert_equal 5, intervention.paragraphs.length
  end
  
  def test_intervention_contains_procedural_text
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2656184')
    expected = "moved for leave to introduce Bill <a href=\"/HousePublications/GetWebOptionsCallBack.aspx?SourceSystem=PRISM&amp;ResourceType=Document&amp;ResourceID=3735387&amp;language=1&amp;DisplayMode=2\" class=\"WebOption\">C-19, An Act to amend the Criminal Code (investigative hearing and recognizance with conditions)</a>."
    
    assert_equal expected, intervention.paragraphs.first
    assert_equal "<div class='procedural_text'>(Motions deemed adopted, bill read the first time and printed)</div>", intervention.paragraphs.last
  end
  
  def test_intervention_with_bracketed_notes_between_paragrahs
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2655585')
    
    assert_match /^I am now prepared to rule/, intervention.paragraphs.first
    assert_equal "The hon. whip of the Bloc Québécois on a point of order.", intervention.paragraphs[-2]
    assert_equal "<div class='timestamp'>(1010)</div>", intervention.paragraphs.last
  end
  
  def test_intervention_with_timestamp_between_paragraphs
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2656407')
    
    assert_equal "<div class='timestamp'>(1050)</div>", intervention.paragraphs[21]
    assert_equal "Omar Khadr's repatriation is long overdue. The bottom line is we must bring Omar Khadr home.", intervention.paragraphs.last
  end
  
  def test_timestamp_after_a_paragraph_gets_picked_up
    assert_not_nil intervention = Intervention.new(@hansard, '#Int-2655875')
    
    assert_equal 6, intervention.paragraphs.length
    assert_equal "<div class='timestamp'>(1020)</div>", intervention.paragraphs.last
  end
end