class RootController < ApplicationController
  def index
  end

  def create
    redirect_to root_path, notice: "CSRF ok"
  end
end
