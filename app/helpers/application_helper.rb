# frozen_string_literal: true

module ApplicationHelper
  def is_admin
    return current_user ? current_user.admin : false
  end
end
