# frozen_string_literal: true

module ApplicationHelper
  def admin?
    current_user&.admin || false
  end

  def breadcrumb_universe
    @universe || @image&.universe || @new_character&.universe # rubocop:disable Rails/HelperInstanceVariable
  end
end
