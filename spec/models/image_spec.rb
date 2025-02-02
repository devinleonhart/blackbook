# == Schema Information
#
# Table name: images
#
#  id          :bigint           not null, primary key
#  caption     :text             default(""), not null
#  favorite    :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  universe_id :integer          not null
#
# Indexes
#
#  index_images_on_universe_id  (universe_id)
#
require "rails_helper"

RSpec.describe Image, type: :model do
end
