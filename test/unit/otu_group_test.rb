require 'test_helper'

class OtuGroupTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end


  def test_otu_group_should_have_generic_search_included
    assert(OtuGroup.included_modules.include?(GenericSearch))
  end

  def test_otu_group_has_following_filters
    assert(OtuGroup.get_filters == [  {"name" => "name", "type" => "string" } ])
  end
end
