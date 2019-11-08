# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::UsersController, type: :controller do
  render_views

  let!(:user) { create :user, display_name: "T. Just T." }

  describe "PUT/PATCH update" do
    subject { put(:update, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(user) }

      context "when the user exists" do
        context "when the parameters are valid" do
          let(:params) do
            {
              id: user.id,
              user: {
                avatar: fixture_file_upload("image.png", "image/png", true),
              },
            }
          end

          include_examples "returns a success HTTP status code"

          it "updates the user's avatar" do
            expect { subject }.to(
              change { user.reload.avatar.attached? }.from(false).to(true)
            )
          end

          it "returns the user's ID" do
            subject
            expect(json["user"]["id"]).to eq(user.reload.id)
          end

          it "returns the user's display name" do
            subject
            expect(json["user"]["display_name"]).to eq("John Smith")
          end

          it "returns the URL for the user's new avatar" do
            subject
            expect(json["user"]["avatar_url"]).to eq(
              Rails.application.routes.url_helpers.rails_blob_path(
                user.reload.avatar,
                only_path: true,
              )
            )
          end
        end

        context "when an ID is passed" do
          let(:params) do
            {
              id: user.id,
              user: { id: -1 },
            }
          end

          include_examples "returns a success HTTP status code"

          it "ignores the ID parameter" do
            expect { subject }.not_to(change { user.reload.id })
          end

          it "returns the user's original ID" do
            original_id = user.id
            subject
            expect(json["user"]["id"]).to eq(original_id)
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
          expect(json["errors"]).to eq([
            "No user with ID -1 exists.",
          ])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: user.id,
          user: { caption: "Stormy weather." },
        }
      end

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
