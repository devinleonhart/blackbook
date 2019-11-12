# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterTraitsController, type: :controller do
  render_views

  let!(:character_trait) do
    create(
      :character_trait,
      trait: trait,
      character: original_character,
    )
  end

  let(:trait) { create :trait, name: "Adventurous" }

  let(:original_character) { create :character, universe: universe }
  let(:new_character) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "PUT/PATCH update" do
    subject { put(:update, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the character's universe" do
      before { authenticate(collaborator) }

      context "when the character trait exists" do
        context "when a Trait exists with the requested name" do
          before { create :trait, name: "Tired" }

          let(:params) do
            {
              id: character_trait.id,
              character_trait: { trait_name: "Tired" },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "doesn't create a new Trait" do
            expect { subject }.not_to change { Trait.count }
          end

          it "updates the character trait's name" do
            subject
            expect(character_trait.reload.trait.name).to(
              eq("Tired")
            )
          end

          it "returns the character trait's ID" do
            subject
            expect(json["character_trait"]["id"]).to eq(character_trait.id)
          end

          it "returns the character trait's new trait name" do
            subject
            expect(json["character_trait"]["name"]).to eq("Tired")
          end
        end

        context "when the new trait name doesn't exist as an Trait" do
          let(:params) do
            {
              id: character_trait.id,
              character_trait: { trait_name: "Tired" },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "creates a new Trait with the requested name" do
            expect { subject }.to change { Trait.count }.by(1)
            expect(Trait.last.name).to eq("Tired")
          end

          it "updates the character trait's name" do
            subject
            expect(character_trait.reload.trait.name).to(
              eq("Tired")
            )
          end

          it "returns the character trait's ID" do
            subject
            expect(json["character_trait"]["id"]).to eq(character_trait.id)
          end

          it "returns the character trait's new trait name" do
            subject
            expect(json["character_trait"]["name"]).to eq("Tired")
          end
        end

        context "when the name parameter isn't valid" do
          let(:params) do
            { id: character_trait.id, character_trait: { trait_name: "" } }
          end

          it { is_expected.to have_http_status(:bad_request) }

          it "doesn't update the character trait's name" do
            subject
            expect { subject }.not_to change {
              character_trait.reload.trait.name
            }
          end

          it "returns an error message for the invalid name" do
            subject
            expect(json["errors"]).to eq(["Name can't be blank"])
          end
        end

        context "when an attempt is made to change the character trait's associated character" do
          let(:params) do
            {
              id: character_trait.id,
              character_trait: {
                character_id: new_character.id,
                trait_name: "Tired",
              },
            }
          end

          it { is_expected.to have_http_status(:success) }

          it "doesn't change the character trait's associated character" do
            expect { subject }.not_to change {
              character_trait.reload.character_id
            }
          end
        end
      end

      context "when the character trait doesn't exist" do
        let(:params) { { id: -1 } }

        it { is_expected.to have_http_status(:not_found) }
      end
    end

    context "when the user is authenticated as a user without an association with the universe" do
      before { authenticate(create(:user)) }

      let(:params) do
        {
          id: character_trait.id,
          character_trait: { trait_name: "Tired" },
        }
      end

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating only the owner or a collaborator can view the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' traits.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) do
        {
          id: character_trait.id,
          character_trait: { trait_name: "Tired" },
        }
      end

      it { is_expected.to have_http_status(:unauthorized) }

      it "returns an error message asking the user to authenticate" do
        subject
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
