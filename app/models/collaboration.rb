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

class Collaboration < ApplicationRecord
  validates :user, uniqueness: { scope: :universe_id }

  belongs_to :user, inverse_of: :collaborations
  belongs_to :universe, inverse_of: :collaborations
end
