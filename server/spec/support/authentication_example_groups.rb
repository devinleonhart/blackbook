# frozen_string_literal: true

RSpec.shared_examples "requires authentication" do |model|
  context "when the user isn't authenticated" do
    it "returns an unauthorized HTTP status code" do
      subject
      expect(response).to have_http_status(:unauthorized)
    end

    it "doesn't create the image_tag" do
      expect { subject }.not_to change { model.count }.from(0)
    end

    it "returns an error message asking the user to authenticate" do
      subject
      expect(json["errors"]).to(
        eq(["You need to sign in or sign up before continuing."])
      )
    end
  end
end
