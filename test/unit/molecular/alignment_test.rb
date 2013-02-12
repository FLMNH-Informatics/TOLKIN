require 'test_helper'

class Molecular::AlignmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  # [ "name",  "description", "seq" ]
  def test_dna_sample_has_following_filters
    assert(Molecular::Alignment.get_filters == [  {"name" => "name", "type" => "string" },  {"name" => "description", "type" => "text" },  { "name" => "seq", "type" => "text" }   ])
  end
end
