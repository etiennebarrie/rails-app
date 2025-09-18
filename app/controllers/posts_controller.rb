class PostsController < ApplicationController
  DOC = JSON.load_file Rails.root.join "../../ruby/json/benchmark/data/twitter.json"

  def index
    render json: DOC
  end
end
