class RootController < ApplicationController
  def index
    ActiveStorage::Current.host = "example.com"
  end
end
