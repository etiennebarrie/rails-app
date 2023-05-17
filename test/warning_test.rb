require "test_helper"

class WarningTest < ActiveSupport::TestCase
  test "warning gets handled by deprecation toolkit" do
    warn "foo"
  end

  test "deprecation warning is handled by deprecation toolkit" do
    warn "deprecated", category: :deprecated
  end
end
