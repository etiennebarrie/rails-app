require "test_helper"

class TestTest < ActiveSupport::TestCase
  test "test with Mocha assertion" do
    TestTest.expects(:hello).once
    TestTest.hello
  end

  test "test with Mocha assertion not incrementing assertions_count" do
    TestTest.expects(:hello).never
    TestTest.hello
  end
end
