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
  describe "validations" do
    describe "for uniqueness" do
      subject { create(:image_tag) }

      it { should validate_uniqueness_of(:character).scoped_to(:image_id) }
    end
  end

  it { should belong_to(:character).required.inverse_of(:image_tags) }
  it { should belong_to(:image).required.inverse_of(:image_tags) }

  it { should delegate_method(:universe).to(:character).allow_nil }
end
