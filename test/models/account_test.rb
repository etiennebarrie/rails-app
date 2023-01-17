require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "can serialize User" do
    user = User.create!
    account = Account.create(blob: user)
    assert_equal account.reload.blob, user
  end
end
