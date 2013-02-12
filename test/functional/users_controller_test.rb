require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # unprivileged users should not be allowed to see a list
  # of other users on the site
  def test_should_not_get_index
    get :index
    assert_response :redirect
    assert_nil assigns(:users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user
    assert_difference('User.count') do
      post :create, :user => { :login => 'mthatcher',
                               :password => 'lbr4all1925',
                               :password_confirmation => 'lbr4all1925',
                               :first_name => 'Margaret',
                               :last_name => 'Thatcher',
                               :email => 'primemin@london.uk',
                               :zipcode => '11011'
                             }
    end

    assert_response :redirect
  end

  def test_should_show_user
    get :show, { :id => users(:nobody).id }, { :user_id => users(:nobody).id }
    assert_response :success
  end

  def test_should_get_edit_for_self
    get :edit, { :id => users(:nobody).id }, { :user_id => users(:nobody).id }
    assert_response :success
  end

  #TODO create test cases to check that user is not able to access another users edit or update controls

  def test_should_update_user
    put :update, { :id => users(:nobody).id, :user => { :first_name => 'Rory' } }, { :user_id => users(:nobody).id }
    assert User.find(users(:nobody)).first_name == 'Rory'
    assert_redirected_to user_path(assigns(:user))
  end

  # a standard use should not be able to destroy themselves - user must be kept,
  # though not necessarily information about them, for data integrity purposes
  def test_should_not_destroy_user
    assert_difference('User.count', 0) do
      delete :destroy, { :id => users(:nobody).id }, { :user_id => users(:nobody).id }
    end
    assert_response :redirect
  end

  #TODO create a test case so that user cannot destroy other users
end
