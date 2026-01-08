# frozen_string_literal: true

module ApplicationHelper
  def admin?
    current_user&.admin || false
  end
end
