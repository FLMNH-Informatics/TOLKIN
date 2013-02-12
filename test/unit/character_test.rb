require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_character_should_have_generic_search_included
    assert(Morphology::Character.included_modules.include?(GenericSearch))
  end

  def test_character_has_following_filters
    assert(Morphology::Character.get_filters == [  {"name" => "name", "type" => "string" },  {"name" => "description", "type" => "text" },  { "name" => "chr_groups_id", "type" => "integer" }])
  end
end
