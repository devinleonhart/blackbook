# frozen_string_literal: true

# == Schema Information
#
# Table name: collaborations
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  universe_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

RSpec.describe Collaboration, type: :model do
end
