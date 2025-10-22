class RootController < ApplicationController
  def index
    render json: { status: "ok" }
  end
end
