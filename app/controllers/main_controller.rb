class MainController < ApplicationController
  def index
    @instance_variable = :instance_variable
  end

  private

  helper_method def controller_helper_method
    :from_controller
  end
end
