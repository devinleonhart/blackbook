# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collaborations", type: :request do
  describe "POST create" do
    context "when signed in as the owner" do
      include_context "with a signed-in owner"

      let(:collaborator) { create(:user) }

      it "creates a collaboration and redirects to universe edit" do
        expect do
          post universe_collaborations_path(universe), params: { collaboration: { user_id: collaborator.id } }
        end.to change(Collaboration, :count).by(1)

        expect(response).to redirect_to(edit_universe_url(universe))
      end

      it "does not create a duplicate collaboration but still redirects with a flash" do
        create(:collaboration, universe: universe, user: collaborator)

        expect do
          post universe_collaborations_path(universe), params: { collaboration: { user_id: collaborator.id } }
        end.not_to change(Collaboration, :count)

        expect(response).to redirect_to(edit_universe_url(universe))
        expect(flash[:error]).to be_present
      end

      it "redirects with a flash when the universe does not exist" do
        post universe_collaborations_path(missing_id), params: { collaboration: { user_id: collaborator.id } }

        expect(response).to redirect_to(universes_url)
        expect(flash[:error]).to be_present
      end
    end

    it "redirects unauthenticated users to sign in" do
      universe = create(:universe)

      expect do
        post universe_collaborations_path(universe), params: { collaboration: { user_id: 123 } }
      end.not_to change(Collaboration, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "DELETE destroy" do
    include_context "with a signed-in owner"

    let(:collaborator) { create(:user) }

    it "destroys the collaboration and redirects to universe edit" do
      collaboration = create(:collaboration, universe: universe, user: collaborator)

      expect do
        delete collaboration_path(collaboration)
      end.to change(Collaboration, :count).by(-1)

      expect(response).to redirect_to(edit_universe_url(universe))
    end

    it "redirects with a flash when the collaboration does not exist" do
      delete collaboration_path(missing_id)

      expect(response).to redirect_to(universes_url)
      expect(flash[:error]).to be_present
    end
  end
end
