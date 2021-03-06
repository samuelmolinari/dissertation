require 'test_helper'

class AuthControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get logout" do
    get :logout
    assert_response :success
  end

  test "should get reset" do
    get :reset
    assert_response :success
  end

  test "should get authenticate" do
    get :authenticate
    assert_response :success
  end

end
