require 'rubygems'
require 'test/unit'

require '../extractor'

class ExtractorTest < Test::Unit::TestCase
  def test_extract_initialize
    extractor = Extractor.new('../hansards/2009-09-12')
    assert_not_nil extractor.contents
  end
end