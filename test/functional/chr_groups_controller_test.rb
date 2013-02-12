require 'test_helper'

class ChrGroupsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:chr_groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_chr_group
    assert_difference('ChrGroup.count') do
      post :create, :chr_group => { }
    end

    assert_redirected_to chr_group_path(assigns(:chr_group))
  end

  def test_should_show_chr_group
    get :show, :id => chr_groups(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => chr_groups(:one).id
    assert_response :success
  end

  def test_should_update_chr_group
    put :update, :id => chr_groups(:one).id, :chr_group => { }
    assert_redirected_to chr_group_path(assigns(:chr_group))
  end

  def test_should_destroy_chr_group
    assert_difference('ChrGroup.count', -1) do
      delete :destroy, :id => chr_groups(:one).id
    end

    assert_redirected_to chr_groups_path
  end
end
