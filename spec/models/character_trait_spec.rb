# frozen_string_literal: true

# == Schema Information
#
# Table name: character_traits
#
#  id           :bigint           not null, primary key
#  character_id :bigint           not null
#  trait_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require "rails_helper"

RSpec.describe CharacterTrait, type: :model do
end
