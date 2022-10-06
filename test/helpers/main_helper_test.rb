require "test_helper"

class MainHelperTest < ActionView::TestCase
  test "main_helper_method" do
    @instance_variable = :instance_variable_test
    assert_equal "instance_variable_test:from_controller_test", main_helper_method
  end

  test "main_partial" do
    output = render "main/main_partial", local_variable: :local_variable_test
    assert_includes output, "local_variable_test"
    assert_select "#main_partial", text: "local_variable_test"
  end

  private

  def controller_helper_method
    :from_controller_test
  end
end
