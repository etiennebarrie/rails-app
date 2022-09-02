require "test_helper"

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_select "body", text: "instance_variable:from_controller"
    assert_response :success
  end
end
