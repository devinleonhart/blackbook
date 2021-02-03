# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageTagsController, type: :controller do
  render_views

  let(:universe) { create :universe }
  let(:collaborator) { create :user }
  let(:image) { create :image, caption: "A great pic." }
  let(:character) { create :character, universe: universe }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "POST create" do
    subject { post(:create, format: :json, params: params) }

    context "when the user has authenticated as a user with access to the universe the character belongs to" do
      before { authenticate(collaborator) }

      context "when the parameters are valid" do
        let(:params) do
          {
            image_id: image.id,
            image_tag: { character_id: character.id },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates an image_tag" do
          expect { subject }.to change { ImageTag.count }.by(1)
        end

        it "sets the new ImageTag's character" do
          subject
          expect(ImageTag.first.character).to eq(character)
        end

        it "sets the new ImageTag's image" do
          subject
          expect(ImageTag.first.image).to eq(image)
        end

        it "returns the new ImageTag's ID" do
          subject
          expect(json["image_tag"]["id"]).to eq(ImageTag.first.id)
        end

        it "returns a description of the new ImageTag's character" do
          subject
          expect(json["image_tag"]["character"]).to eq(
            "id" => character.id,
            "name" => character.name,
          )
        end

        it "returns a description of the new ImageTag's image" do
          subject
          expect(json["image_tag"]["image"]["id"]).to eq(image.id)
          expect(json["image_tag"]["image"]["url"]).to(
            start_with("/rails/active_storage/blobs/")
          )
        end
      end

      context "when an id parameter is passed" do
        let(:params) do
          {
            image_id: image.id,
            image_tag: {
              id: -1,
              character_id: character.id,
            },
          }
        end

        it { is_expected.to have_http_status(:success) }

        it "creates an image_tag" do
          expect { subject }.to change { ImageTag.count }.by(1)
        end

        it "ignores the ID parameter" do
          subject
          expect(ImageTag.first.id).not_to eq(-1)
        end
      end

      context "when an invalid character ID is passed" do
        let(:params) do
          {
            image_id: image.id,
            image_tag: { character_id: -1 },
          }
        end

        it { is_expected.to have_http_status(:not_found) }

        it "doesn't create an ImageTag" do
          expect { subject }.not_to change { ImageTag.count }
        end

        it "returns an error message for the invalid character ID" do
          subject
          expect(json["errors"]).to eq(["No character with ID -1 exists."])
        end
      end
    end

    context "when the user doesn't have access to the universe" do
      before { authenticate(create(:user)) }

      let(:params) do
        {
          image_id: image.id,
          image_tag: { character_id: character.id },
        }
      end

      it { is_expected.to have_http_status(:forbidden) }

      it "doesn't create the image_tag" do
        expect { subject }.not_to change { ImageTag.count }
      end

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq([<<~ERROR_MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' images.
          ERROR_MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          image_id: image.id,
          image_tag: { character_id: character.id },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "doesn't create the image_tag" do
        expect { subject }.not_to change { ImageTag.count }
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
