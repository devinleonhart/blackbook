# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImagesController, type: :controller do
  render_views

  let!(:image) { create :image, caption: "A great pic." }

  describe "DELETE destroy" do
    subject { delete(:destroy, format: :json, params: params) }

    context "when the user is authenticated" do
      before { authenticate(create(:user)) }

      context "when the Image exists" do
        let(:params) { { id: image.id } }

        it { is_expected.to have_http_status(:success) }

        it "deletes the image" do
          expect { subject }.to change { Image.count }.by(-1)
        end
      end

      context "when the Image doesn't exist" do
        let(:params) { { id: -1 } }

        it "returns a Not Found Response" do
          subject
          expect(response).to have_http_status(:not_found)
        end

        it "returns an error message informing the user the resource doesn't exist" do
          subject
          expect(json["errors"]).to eq(["No image with ID -1 exists."])
        end
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { id: image.id } }

      it "returns an unauthorized HTTP status code" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it "doesn't destroy the image" do
        expect { subject }.not_to change { Image.count }
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
