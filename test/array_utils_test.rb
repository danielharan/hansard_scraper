require 'test_helper'
require '../array_utils'

class ArrayUtilsTest < Test::Unit::TestCase
  def test_firsts_in_sequence
    assert_equal [1,2,1,2,3], ArrayUtils.firsts_in_sequence([1,1,1,1,2,1,1,1,2,2,2,2,2,2,2,3,3])
  end
end