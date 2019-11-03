# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharacterItemsController, type: :controller do
  render_views

  let!(:character_item1) do
    create :character_item, item: item1, character: character1
  end
  let(:item1) { create :item, name: "Wrench" }
  let!(:character_item2) do
    create :character_item, item: item2, character: character1
  end
  let(:item2) { create :item, name: "Pliers" }
  let!(:character_item3) do
    create :character_item, item: item3, character: character2
  end
  let(:item3) { create :item, name: "Toolbox" }

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }
  let(:universe) { create :universe }
  let(:collaborator) { create :user }

  before do
    universe.collaborators << collaborator
    universe.save!
  end

  describe "GET index" do
    subject do
      get(
        :index,
        format: :json,
        params: params,
      )
    end

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      context "and the requested character is in that universe" do
        let(:params) do
          { universe_id: universe.id, character_id: character1.id }
        end

        it "returns the IDs only for CharacterItems belonging to the given character" do
          subject
          expected_values = [character_item1.id, character_item2.id]
          received_values = json.collect do |character_item|
            character_item["id"]
          end
          expect(received_values).to match_array(expected_values)
        end

        it "returns the names only for CharacterItems belonging to the given character" do
          subject
          expected_values = [
            character_item1.item.name,
            character_item2.item.name,
          ]
          received_values = json.collect do |character_item|
            character_item["name"]
          end
          expect(received_values).to match_array(expected_values)
        end

        it "returns a success HTTP status code" do
          subject
          expect(response).to have_http_status(:success)
        end
      end

      context "and the requested character isn't in that universe" do
        let(:non_universe_character) { create :character }

        let(:params) do
          { universe_id: universe.id, character_id: non_universe_character.id }
        end

        it "returns a Bad Request status" do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "returns an error message for the character not belonging to the universe" do
          subject
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Character with ID #{non_universe_character.id} does not belong to
            Universe #{universe.id}.
          ERROR_MESSAGE
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before do
        authenticate(create(:user))
        get(
          :index,
          format: :json,
          params: { universe_id: universe.id, character_id: character1.id }
        )
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating this user can't interact with the universe" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its characters' items.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before do
        get(
          :index,
          format: :json,
          params: { universe_id: universe.id, character_id: character1.id },
        )
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message asking the user to authenticate" do
        expect(json["errors"]).to(
          eq(["You need to sign in or sign up before continuing."])
        )
      end
    end
  end
end
