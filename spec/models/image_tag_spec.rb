# frozen_string_literal: true

# == Schema Information
#
# Table name: image_tags
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  image_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe ImageTag, type: :model do
end
