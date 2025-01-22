require "test_helper"

class DeprecationTest < ActiveSupport::TestCase
  test "deprecation" do
    assert_equal "null", [].to_s(:db)
  end
end
