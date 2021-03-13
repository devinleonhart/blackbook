# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id              :bigint           not null, primary key
#  avatar          :boolean          default(FALSE), not null
#  caption         :text             default(""), not null
#  universe_avatar :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  universe_id     :bigint           not null
#
# Indexes
#
#  index_images_on_universe_id  (universe_id)
#

require "rails_helper"

RSpec.describe Image, type: :model do
end
