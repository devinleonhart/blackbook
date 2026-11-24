# frozen_string_literal: true

module BlackbookMcp
  # One page of a list.
  module Page
    PER_PAGE = 50

    def self.of(scope, arguments, &)
      page = arguments.fetch(:page, 1)
      per_page = arguments.fetch(:per_page, PER_PAGE)
      total = scope.count
      records = scope.limit(per_page).offset((page - 1) * per_page).to_a
      { items: yield(records), total: total, page: page, next_page: (page + 1 if page * per_page < total) }
    end
  end
end
