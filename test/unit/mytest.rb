# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

#require 'test/unit'
#require 'mytest'

class FirstTests < Test::Unit::TestCase

  def setup
    # this method gets called before each test
    @string = "Unit testing is not difficult."
    @array = [1,2,3,4,5]
  end

  def test_subtraction
    assert(2 - 1 == 2)  # should fail
    assert(1 - 1 == 0)  # should succeed
  end

  def test_addition
    assert(1 + 1 == 2, "Addition should work.")
  end

  def test_array_a
    assert(5 == @array.length)
    @array << 6
    assert_equal(6, @array.length)
    assert_equal([6,5,4,3,2,1], reverse_array(@array))
  end

  def test_array_b
    assert_equal([5,4,3,2,1], reverse_array(@array),
        "@array should not be affected by other tests.")
  end

  def reverse_array(array)
    return array.reverse
  end

  def test_string
    assert_equal(30, @string.length)
    assert_equal(0, @fake_string.length)
  end

  def dont_test_string_content
    assert_equal("Unit testing is not difficult.", @string)
  end
 
  
end
