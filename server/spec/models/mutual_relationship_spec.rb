# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MutualRelationship, type: :model do
  it {
    should(
      have_many(:relationships)
      .inverse_of(:mutual_relationship)
      .dependent(:destroy)
    )
  }
end
