class ThreadCurrent < ActiveSupport::CurrentAttributes
  self._use_thread_variables = true

  attribute :random
end
