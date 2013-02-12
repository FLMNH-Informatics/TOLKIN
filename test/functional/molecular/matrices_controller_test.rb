require 'test_helper'

class Molecular::MatricesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "should show matrix" do
    get :index
    assert_response :success
  end
end
