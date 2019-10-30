# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::V1::CharactersController, type: :controller do
  render_views

  let!(:universe1) { create :universe }
  let!(:universe2) { create :universe }

  let(:collaborator) { create :user }

  before do
    universe1.collaborators << collaborator
    universe1.save!
  end

  describe "GET index" do
    context "when the user is authenticated as a user with access to the universe" do
      before do
        authenticate(collaborator)
      end

      let!(:character1) do
        create :character, name: "Lil Kay", universe: universe1
      end
      let!(:character2) do
        create :character, name: "Osgood", universe: universe1
      end
      let!(:character3) do
        create :character, name: "Scarlet", universe: universe2
      end
      let!(:character4) do
        create :character, name: "Elise", universe: universe1
      end
      let!(:character5) do
        create :character, name: "Nicolette", universe: universe1
      end
      let!(:character6) do
        create :character, name: "Dale", universe: universe1
      end
      let!(:character7) do
        create :character, name: "Sophie", universe: universe1
      end
      let!(:character8) do
        create :character, name: "Gabe", universe: universe1
      end

      context "when the user requests pagination" do
        before do
          get(
            :index,
            format: :json,
            params: {
              universe_id: universe1.id,
              page: 3,
              page_size: 2,
            }
          )
        end

        include_examples "returns a success HTTP status code"

        it "returns the page this character list is on" do
          expect(json["page"]).to eq(3)
        end

        it "returns the size of each page" do
          expect(json["page_size"]).to eq(2)
        end

        it "returns the total number of pages" do
          expect(json["total_pages"]).to eq(4)
        end

        it "returns the IDs for the characters on the requested page" do
          character_names = json["characters"].collect { |entry| entry["id"] }
          expect(character_names).to eq([character6.id, character7.id])
        end

        it "returns the names for the characters on the requested page" do
          character_names = json["characters"].collect { |entry| entry["name"] }
          expect(character_names).to eq(["Dale", "Sophie"])
        end
      end

      context "when the user omits custom pagination" do
        before do
          get(:index, format: :json, params: { universe_id: universe1.id })
        end

        it "defaults to returning page 1" do
          expect(json["page"]).to eq(1)
        end

        it "defaults to the page size configuration setting" do
          expect(json["page_size"]).to eq(
            Rails.configuration.pagination_default_page_size
          )
        end

        it "returns the total number of pages" do
          # Note that this number will have to be adjusted if the default page
          # size drops below 7. I didn't want to reproduce the logic to
          # dynamically calculate page size here because I would just be
          # asserting that the output of my page count calculation equals
          # itself, testing nothing.
          expect(json["total_pages"]).to eq(1)
        end

        it "returns the IDs for the characters on the requested page" do
          character_names = json["characters"].collect { |entry| entry["id"] }
          expect(character_names).to eq([
            character1.id,
            character2.id,
            character4.id,
            character5.id,
            character6.id,
            character7.id,
            character8.id,
          ])
        end

        it "returns the names for the characters on the requested page" do
          character_names = json["characters"].collect { |entry| entry["name"] }
          expect(character_names).to eq([
            "Lil Kay",
            "Osgood",
            "Elise",
            "Nicolette",
            "Dale",
            "Sophie",
            "Gabe",
          ])
        end
      end

      context "when the user requests a page beyond the total number of pages" do
        before do
          get(
            :index,
            format: :json,
            params: {
              universe_id: universe1.id,
              page: 100,
              page_size: 10,
            }
          )
        end

        include_examples "returns a success HTTP status code"

        it "returns an empty characters list" do
          expect(json["characters"]).to eq([])
        end
      end

      context "when the user requests an invalid page" do
        before do
          get(
            :index,
            format: :json,
            params: {
              universe_id: universe1.id,
              page: 0,
              page_size: 2,
            }
          )
        end

        it "returns a Bad Request HTTP status code" do
          expect(response).to have_http_status(:bad_request)
        end

        it "returns a message describing the invalid parameter" do
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Invalid page parameter value: 0. Pages start at 1.
          ERROR_MESSAGE
        end
      end

      context "when the user requests an invalid page size" do
        before do
          get(
            :index,
            format: :json,
            params: {
              universe_id: universe1.id,
              page: 3,
              page_size: 0,
            }
          )
        end

        it "returns a Bad Request HTTP status code" do
          expect(response).to have_http_status(:bad_request)
        end

        it "returns a message describing the invalid parameter" do
          expect(json["errors"]).to eq([<<~ERROR_MESSAGE.squish])
            Invalid page_size parameter value: 0. Page size must be at least 1.
          ERROR_MESSAGE
        end
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before do
        authenticate(create(:user))
        get(:index, format: :json, params: { universe_id: universe1.id })
      end

      it "returns a forbidden HTTP status code" do
        expect(response).to have_http_status(:forbidden)
      end

      it "returns an error message indicating this user can't interact with the universe" do
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe1.id} to interact with its characters.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      before do
        get(:index, format: :json, params: { universe_id: universe1.id })
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
