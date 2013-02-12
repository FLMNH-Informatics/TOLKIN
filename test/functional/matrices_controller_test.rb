require 'test_helper'

class MatricesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:matrices)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_matrix
    assert_difference('Matrix.count') do
      post :create, :matrix => { }
    end

    assert_redirected_to matrix_path(assigns(:matrix))
  end

  def test_should_show_matrix
    get :show, :id => matrices(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => matrices(:one).id
    assert_response :success
  end

  def test_should_update_matrix
    put :update, :id => matrices(:one).id, :matrix => { }
    assert_redirected_to matrix_path(assigns(:matrix))
  end

  def test_should_destroy_matrix
    assert_difference('Matrix.count', -1) do
      delete :destroy, :id => matrices(:one).id
    end

    assert_redirected_to matrices_path
  end
end
