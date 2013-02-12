require 'test_helper'

class OtuGroupsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, {:project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
    assert_not_nil assigns(:otu_groups_list)
  end

  def test_should_get_xhr_new
    get :index, {:project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    xhr :get, :new, { :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
    assert_not_nil assigns(:otu_group)
  end

  def test_should_create_otu_group
    assert_difference('OtuGroup.count') do
      post :create, { :otu_group => { :name => 'my new OTU Group' }, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    end
  end

  def test_should_show_otu_group
    get :show, { :id => otu_groups(:added_by_updater).id, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, { :id => otu_groups(:added_by_updater).id, :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    assert_response :success
  end

  def test_should_update_otu_group
    put :update, {
      :id => otu_groups(:added_by_updater).id,
      :otu_group => { :name => 'time for a new name' },
      :project_id => projects(:viridiplantae).id
    },
      :user_id => users(:updater).id
    assert assigns(:otu_group).name == 'time for a new name'
  end

  def test_should_destroy_otu_group
    assert_difference('OtuGroup.count', -1) do
      post :delete_selected, { :otu_groups => [ otu_groups(:added_by_updater).id ], :project_id => projects(:viridiplantae).id }, :user_id => users(:updater).id
    end
  end
end
