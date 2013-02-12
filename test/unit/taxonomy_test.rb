require 'test_helper'

class TaxonomyTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_uniqueness_of_name
    tax = Taxonomy.new
    tax.name = "taxon one"
    tax.updated_at = Time.now
    tax.project_id = 1
    tax.user_id = 1
    tax.recpermission_id = 1
    tax.last_updated_by_id =1
    assert(tax.save, "uniqueness of name failed" )
  end

  def test_save
    tax = Taxonomy.new
    tax.name = "taxon one"
    tax.updated_at = Time.now
    tax.project_id = 1
    tax.user_id = 1
    tax.recpermission_id = 1
    tax.last_updated_by_id =1
    assert(tax.save, tax.errors.full_messages.join(", "))
  end
end
