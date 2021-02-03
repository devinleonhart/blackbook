# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  render_views

  let!(:user) do
    create(
      :user,
      display_name: "T. Just T.",
      avatar:
        Rack::Test::UploadedFile.new("spec/fixtures/image.png", "image/png"),
    )
  end

  describe "GET show" do
    subject { get(:show, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(user) }

      context "when the user exists" do
        let(:params) { { id: user.id } }

        it { is_expected.to have_http_status(:success) }

        it "returns the user's ID" do
          subject
          expect(json["user"]["id"]).to eq(user.id)
        end

        it "returns the user's display name" do
          subject
          expect(json["user"]["display_name"]).to eq("T. Just T.")
        end

        it "returns the URL for the user's avatar" do
          subject
          expect(json["user"]["avatar_url"]).to eq(
            Rails.application.routes.url_helpers.rails_blob_path(
              user.avatar,
              only_path: true,
            )
          )
        end

        context "when the user doesn't have an avatar" do
          let!(:user) { create :user, display_name: "T. Just T." }

          it "returns nil for the user's avatar" do
            subject
            expect(json["user"]["avatar_url"]).to be_nil
          end
        end
      end

      context "when the user doesn't exist" do
        let(:params) { { id: -1 } }

        it "responds with a Not Found HTTP status code" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message indicating the user doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No user with ID -1 exists."])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: user.id } }

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
