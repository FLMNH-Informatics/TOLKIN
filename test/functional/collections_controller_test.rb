require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  # created due to bug
  def test_item_list_with_null_taxonomy
    get :index, { :project_id => projects(:viridiplantae).id }, { :user_id => users(:updater).id }
    assert_response :success
  end
end
