module MainHelper
  def main_helper_method
    [@instance_variable, controller_helper_method, application].join(":")
  end
end
