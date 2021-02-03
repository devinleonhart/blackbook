# frozen_string_literal: true

require "rails_helper"

RSpec.describe MutualRelationshipsController, type: :controller do
  render_views

  let!(:mutual_relationship1) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Father",
      reverse_name: "Daughter",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship2) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character2,
      forward_name: "Mentor",
      reverse_name: "Student",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship3) do
    create(
      :mutual_relationship,
      character1: character2,
      character2: character1,
      forward_name: "Secret Santa gift-giver",
      reverse_name: "Secret Santa gift-recipient",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship4) do
    create(
      :mutual_relationship,
      character1: character1,
      character2: character3,
      forward_name: "Father",
      reverse_name: "Daughter",
      character_universe: universe,
    )
  end
  let!(:mutual_relationship5) do
    create(
      :mutual_relationship,
      character1: character2,
      character2: character3,
      forward_name: "Sister",
      reverse_name: "Sister",
      character_universe: universe,
    )
  end

  let(:character1) { create :character, universe: universe }
  let(:character2) { create :character, universe: universe }
  let(:character3) { create :character, universe: universe }

  let(:universe) do
    universe = build :universe
    universe.collaborators << collaborator
    universe.save!
    universe
  end
  let(:collaborator) { create :user }

  describe "GET index" do
    subject { get(:index, format: :json, params: params) }

    context "when the user is authenticated as a user with access to the universe" do
      before { authenticate(collaborator) }

      let(:params) { { character_id: character1.id } }

      it "returns the first relationship from character1 to character2" do
        subject
        expect(json).to include(
          "id" => mutual_relationship1.id,
          "name" => "Father",
          "target_character" => {
            "id" => character2.id,
            "name" => character2.name,
          },
        )
      end

      it "returns the second relationship from character1 to character2" do
        subject
        expect(json).to include(
          "id" => mutual_relationship2.id,
          "name" => "Mentor",
          "target_character" => {
            "id" => character2.id,
            "name" => character2.name,
          },
        )
      end

      it "returns the third relationship from character1 to character2" do
        subject
        expect(json).to include(
          "id" => mutual_relationship3.id,
          "name" => "Secret Santa gift-recipient",
          "target_character" => {
            "id" => character2.id,
            "name" => character2.name,
          },
        )
      end

      it "returns the first relationship from character1 to character3" do
        subject
        expect(json).to include(
          "id" => mutual_relationship4.id,
          "name" => "Father",
          "target_character" => {
            "id" => character3.id,
            "name" => character3.name,
          },
        )
      end

      it "returns only the four relevant relationships" do
        subject
        expect(json.length).to eq(4)
      end
    end

    context "when the user is authenticated as a user who doesn't have access to the universe" do
      before { authenticate(create(:user)) }

      let(:params) { { character_id: character1.id } }

      it { is_expected.to have_http_status(:forbidden) }

      it "returns an error message indicating this user can't interact with the universe" do
        subject
        expect(json["errors"]).to(
          eq([<<~MESSAGE.squish])
            You must be an owner or collaborator for the universe with ID
            #{universe.id} to interact with its relationships.
          MESSAGE
        )
      end
    end

    context "when the user isn't authenticated" do
      let(:params) { { character_id: character1.id } }

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
