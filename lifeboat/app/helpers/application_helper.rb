# frozen_string_literal: true

module ApplicationHelper
  def flash_class(level)
    levels = {
      "notice" => "alert alert-info",
      "success" => "alert alert-success",
      "error" => "alert alert-danger",
      "alert" => "alert alert-danger",
    }
    levels[level]
  end
end
