require 'test_helper'

class OtusControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, {:project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
    assert_not_nil assigns(:otus)
  end

  def test_should_get_xhr_new
    get :index, {:project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    xhr :get, :new, { :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_not_nil assigns(:otus)
    assert_response :success
  end

  def test_should_create_otu
    assert_difference('Otu.count') do
      post :create, { :otu => { :name => 'my new OTU'}, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    end
  end

  def test_should_show_otu
    get :show, { :id => otus(:added_by_updater).id, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, { :id => otus(:added_by_updater).id, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
  end

  def test_should_update_otu
    put :update, { :id => otus(:added_by_updater).id, :project_id => projects(:viridiplantae).id, :otu => { :name => 'name_changed' } }, { :user_id => users(:updater).id }
    assert assigns(:otu).name == 'name_changed'
  end

  def test_should_destroy_otu
    assert_difference('Otu.count', -1) do
      post :delete_selected, { :otus => [ otus(:added_by_updater).id ], :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    end
  end
end
