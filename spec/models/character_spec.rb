# frozen_string_literal: true

# == Schema Information
#
# Table name: characters
#
#  id           :bigint           not null, primary key
#  name         :citext           not null
#  description  :string           not null
#  universe_id  :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

require "rails_helper"

RSpec.describe Character, type: :model do
end
