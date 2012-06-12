require 'test_helper'

class ManageControllerTest < ActionController::TestCase
  test "should get albums" do
    get :albums
    assert_response :success
  end

  test "should get album" do
    get :album
    assert_response :success
  end

  test "should get photos" do
    get :photos
    assert_response :success
  end

  test "should get photo" do
    get :photo
    assert_response :success
  end

  test "should get tags" do
    get :tags
    assert_response :success
  end

  test "should get faces" do
    get :faces
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
