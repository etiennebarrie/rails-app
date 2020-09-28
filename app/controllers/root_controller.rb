class RootController < ApplicationController
  before_action :set_current

  def index
  end

private

  def set_current
    Current.random ||= rand(100)
    ThreadCurrent.random ||= rand(100)
  end

  helper_method def enumerator
    Enumerator.new do |yielder|
      yielder.yield yield
    end
  end
end
