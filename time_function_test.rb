require 'minitest/autorun'
require_relative 'date_compute'

class DateComputeTests < MiniTest::Test
  def test_basic_example
    result = DateCompute.convert_time('01/1900', '0616')
    assert_equal('02/0116', result)
  end
end
