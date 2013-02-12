require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, { }, { :user_id => users(:twoprojects) }
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  # a user with only one active project should automatically enter
  # that project when they log in
  def test_should_get_index_redirect_to_search
    get :index, { }, { :user_id => users(:updater) }
    assert_redirected_to search_path(projects(:viridiplantae))
  end

  def test_should_get_new
    get :new, { }, { :user_id => users(:manager) }
    assert_response :success
  end

  def test_should_create_project
    assert_difference('Project.count') do
      post :create, { :project => { :name => 'Animalia Project' } }, { :user_id => users(:manager) }
    end

    assert_redirected_to projects_path
  end

  def test_should_show_project
    get :show, { :id => projects(:viridiplantae).id }, { :user_id => users(:updater) }
    assert_redirected_to search_path(projects(:viridiplantae))
  end

  def test_should_get_edit
    get :edit, { :id => projects(:viridiplantae).id }, { :user_id => users(:manager) }
    assert_response :success
  end

  def test_should_update_project
    put :update, { :id => projects(:viridiplantae).id, :project => { :name => 'Animalia Project' } }, { :user_id => users(:manager) }
    assert Project.find(projects(:viridiplantae)).name == 'Animalia Project'
  end
end
