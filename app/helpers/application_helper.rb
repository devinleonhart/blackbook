# frozen_string_literal: true

module ApplicationHelper
  def admin?
    current_user&.admin || false
  end

  # The universe to surface in the navbar breadcrumb, if any — derived from
  # whichever record the current page is about. Reading the controller-set
  # ivars is the pragmatic pattern for a breadcrumb in the shared layout.
  def breadcrumb_universe
    @universe || @image&.universe || @new_character&.universe # rubocop:disable Rails/HelperInstanceVariable
  end
end
