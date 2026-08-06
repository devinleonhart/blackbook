# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users management", type: :request do
  describe "DELETE destroy" do
    let(:victim) { create(:user) }

    context "when the user is an admin" do
      before { sign_in(create(:user, admin: true)) }

      it "deletes the user and redirects to the user list" do
        victim

        expect do
          delete user_path(victim)
        end.to change(User, :count).by(-1)

        expect(response).to redirect_to(users_url)
      end

      it "shows an error when the user cannot be deleted" do
        allow(User).to receive(:find_by).and_return(victim)
        allow(victim).to receive_messages(
          destroy: false,
          errors: instance_double(ActiveModel::Errors, full_messages: ["nope"])
        )

        delete user_path(victim)

        expect(response).to redirect_to(users_url)
        expect(flash[:error]).to be_present
      end
    end

    context "when the user is not an admin" do
      it "is blocked and leaves the user intact" do
        sign_in(create(:user, admin: false))

        delete user_path(victim)

        expect(response).to redirect_to(universes_url)
        expect(User.where(id: victim.id)).to exist
      end
    end
  end
end
