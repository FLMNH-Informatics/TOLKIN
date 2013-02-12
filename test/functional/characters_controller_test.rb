require 'test_helper'

class CharactersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:characters)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_character
    assert_difference('Character.count') do
      post :create, :character => { }
    end

    assert_redirected_to character_path(assigns(:character))
  end

  def test_should_show_character
    get :show, :id => characters(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => characters(:one).id
    assert_response :success
  end

  def test_should_update_character
    put :update, :id => characters(:one).id, :character => { }
    assert_redirected_to character_path(assigns(:character))
  end

  def test_should_destroy_character
    assert_difference('Character.count', -1) do
      delete :destroy, :id => characters(:one).id
    end

    assert_redirected_to characters_path
  end
end
