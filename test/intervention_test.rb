require 'test_helper'
require '../intervention'

class InterventionTest < Test::Unit::TestCase
  def test_initialize
    assert_not_nil Intervention.new
  end
end