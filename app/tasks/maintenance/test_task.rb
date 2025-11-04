# frozen_string_literal: true

module Maintenance
  class TestTask < MaintenanceTasks::Task
    def collection
      (1..10).to_a
    end

    def process(element)
      Rails.logger.debug "Processing #{element}"
    end
  end
end
