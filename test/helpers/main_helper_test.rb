require "test_helper"

class MainHelperTest < ActionView::TestCase
  test "main_helper_method" do
    @instance_variable = :instance_variable_test
    assert_equal "instance_variable_test:from_controller_test", main_helper_method
  end

  private

  def controller_helper_method
    :from_controller_test
  end
end
