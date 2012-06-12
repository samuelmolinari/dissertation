require 'test_helper'

class NotificationCentreControllerTest < ActionController::TestCase
  test "should get recognition" do
    get :recognition
    assert_response :success
  end

end
