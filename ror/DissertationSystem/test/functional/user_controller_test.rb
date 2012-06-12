require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get photos" do
    get :photos
    assert_response :success
  end

  test "should get photo" do
    get :photo
    assert_response :success
  end

  test "should get albums" do
    get :albums
    assert_response :success
  end

  test "should get album" do
    get :album
    assert_response :success
  end

end
