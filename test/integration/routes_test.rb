require "test_helper"

class RoutesTest < ActionDispatch::IntegrationTest
  test "the truth" do
    assert_routing("/up", { controller: "rails/health", action: "show" })
  end
end
