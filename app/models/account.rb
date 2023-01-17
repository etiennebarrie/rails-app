class Account < ApplicationRecord
  serialize :blob, User
end
