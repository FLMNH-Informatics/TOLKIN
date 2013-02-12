require 'test_helper'

class OtuTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    print "test_truth"
    assert true
  end

  def test_otu_should_have_generic_search_included
    assert(Otu.included_modules.include?(GenericSearch))
  end

  def test_otu_has_following_filters
    assert(Otu.get_filters == [  {"name" => "name", "type" => "string" } ,  {"name" => "description", "type" => "text" },
      { "name" => "otu_groups_id", "type" => "integer"} ])
  end
end
