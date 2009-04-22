require 'test_helper'
require File.join(File.dirname(__FILE__), '..', 'intervention')

class InterventionTest < Test::Unit::TestCase
  def test_initialize
    assert_not_nil Intervention.new
  end
end