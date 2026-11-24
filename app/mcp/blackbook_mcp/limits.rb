# frozen_string_literal: true

module BlackbookMcp
  # Counts in memory, since there is one process. Each window starts with its first count.
  module Limits
    CALLS = 120
    FAILURES = 20
    WINDOW = 1.minute
    STORE = ActiveSupport::Cache::MemoryStore.new(size: 4.megabytes)

    module_function

    def call_allowed?(token)
      increment("call/#{token.id}") <= CALLS
    end

    def failures_exceeded?(address)
      STORE.read("failure/#{address}").to_i >= FAILURES
    end

    def count_failure(address)
      increment("failure/#{address}")
    end

    def reset
      STORE.clear
    end

    def increment(key)
      STORE.increment(key, 1, expires_in: WINDOW)
    end
  end
end
