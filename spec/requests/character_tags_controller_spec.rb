# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CharacterTags", type: :request do
  def sign_in_as(user, password: "password123")
    post user_session_path, params: { user: { email: user.email, password: password } }
    expect(response).to have_http_status(:found)
  end

  it "redirects unauthenticated users" do
    character = create(:character)
    get character_character_tags_path(character)
    expect(response).to have_http_status(:found)
  end

  it "lists tags for a character" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    create(:character_tag, character: character, name: "elf")

    sign_in_as(owner)
    get character_character_tags_path(character)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("elf")
  end

  it "creates a tag (normalizes to lowercase) and redirects to the character" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)

    sign_in_as(owner)
    post character_character_tags_path(character), params: { character_tag: { name: "Elf" } }

    expect(response).to redirect_to(character_path(character))
    expect(character.character_tags.reload.map(&:name)).to include("elf")
  end

  it "shows a tag, including related images" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    tag = create(:character_tag, character: character, name: "mage")

    image = create(:image, universe: universe)
    create(:image_tag, image: image, character: character)

    sign_in_as(owner)
    get character_tag_path(tag)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("mage")
  end

  it "updates a tag and redirects back to the character tags index" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    tag = create(:character_tag, character: character, name: "human")

    sign_in_as(owner)
    patch character_tag_path(tag), params: { character_tag: { name: "noble" } }

    expect(response).to redirect_to(character_character_tags_path(character))
    expect(tag.reload.name).to eq("noble")
  end

  it "destroys a tag and redirects back to the character tags index" do
    owner = create(:user)
    universe = create(:universe, owner: owner)
    character = create(:character, universe: universe)
    tag = create(:character_tag, character: character, name: "warrior")

    sign_in_as(owner)
    delete character_tag_path(tag)

    expect(response).to redirect_to(character_character_tags_path(character))
    expect(CharacterTag.where(id: tag.id)).not_to exist
  end
end
