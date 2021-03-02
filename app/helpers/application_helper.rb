# frozen_string_literal: true

module ApplicationHelper
  def flash_class(level)
    levels = {
      "notice" => "alert alert-info",
      "success" => "alert alert-success",
      "error" => "alert alert-error",
      "alert" => "alert alert-error",
    }
    levels[level]
  end
end
