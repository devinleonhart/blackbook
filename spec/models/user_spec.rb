# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  display_name           :citext           not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_display_name          (display_name) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require "rails_helper"

RSpec.describe User, type: :model do

  before do
    @user1 = FactoryBot.build(:user, { display_name: "Max Lionheart", email: "test@test.com" })
  end

  it "should not allow display_name to be nil" do
    @user1.display_name = nil
    expect(@user1).to be_invalid
  end

  it "should not allow an empty display_name" do
    @user1.display_name = ""
    expect(@user1).to be_invalid
  end

  it "should not allow a duplicate display_name" do
    @user1.save!
    @user2 = FactoryBot.build(:user, { display_name: "Max Lionheart" })
    expect(@user2).to be_invalid
  end

  it "should not allow email to be nil" do
    @user1.email = nil
    expect(@user1).to be_invalid
  end

  it "should not allow an empty email" do
    @user1.email = ""
    expect(@user1).to be_invalid
  end

  it "should not allow a duplicate email" do
    @user1.save!
    @user2 = FactoryBot.build(:user, { email: "test@test.com" })
    expect(@user2).to be_invalid
  end
end
