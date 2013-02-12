require 'test_helper'

class DnaSampleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_dna_sample_has_following_filters
    assert(Molecular::DnaSample.get_filters == [  {"name" => "amount", "type" => "string" },  {"name" => "collection_id", "type" => "integer" },  { "name" => "deposited", "type" => "string" } ,  { "name" => "extraction_protocol", "type" => "string" }  ,  { "name" => "guid", "type" => "string" }      ,  { "name" => "loc_box", "type" => "string" }       ,  { "name" => "loc_column", "type" => "string" }       ,  { "name" => "loc_freezer", "type" => "string" }      ,  { "name" => "loc_rack_bag", "type" => "string" }      ,  { "name" => "loc_row", "type" => "string" }      ,  { "name" => "loc_shelf_bin", "type" => "string" }      ,  { "name" => "notes", "type" => "string" }      ,  { "name" => "sample_nr", "type" => "string" }      ,  { "name" => "sample_type", "type" => "string" }      ,   { "name" => "source", "type" => "string" }  ,  { "name" => "taxonomy_id", "type" => "integer" }      ,  { "name" => "team", "type" => "string" }      ])
  end
end
