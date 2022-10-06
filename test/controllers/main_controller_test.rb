require "test_helper"

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_select "#main_helper_method", text: "instance_variable:from_controller"
    assert_select "#main_partial", text: "local_variable"
    assert_response :success
  end
end
