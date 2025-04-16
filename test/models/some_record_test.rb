require "test_helper"

class SomeRecordTest < ActiveSupport::TestCase
  test "simulate gem deprecation" do
    MaintenanceTasks.deprecator.warn("this is deprecated")
    pass
  end
end
