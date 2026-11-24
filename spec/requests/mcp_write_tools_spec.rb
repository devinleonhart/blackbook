# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP write tools", type: :request do
  include_context "with MCP"

  let!(:aria) { create(:character, universe: universe, name: "Aria") }
  let!(:trait) { create(:trait, character: aria, name: "knight") }
  let!(:image) { create(:image, universe: universe) }
  let!(:foreign) { create(:character, universe: foreign_universe) }
  let!(:foreign_trait) { create(:trait, character: foreign) }
  let!(:foreign_image) { create(:image, universe: foreign_universe) }

  def write(name, arguments)
    tool_data(name, arguments, token: writer)
  end

  def everything
    [Universe, Character, Trait, Appearance, ImageFavorite, Image].index_with { |m| m.order(:id).map(&:attributes) }
  end

  it "creates a character as the site does" do
    result = write("create_character", { universe_id: universe.id, name: "Cora" })
    sign_in(user)
    post universe_characters_path(universe), params: { character: { name: "Dana" } }
    mine, theirs = %w[Cora Dana].map { |name| Character.find_by!(name: name) }

    expect(result).to include("id" => mine.id, "name" => "Cora", "universe_id" => universe.id, "traits" => [])
    expect(mine.attributes.except("id", "name", "created_at", "updated_at"))
      .to eq(theirs.attributes.except("id", "name", "created_at", "updated_at"))
  end

  it "renames a character" do
    expect(write("update_character", { id: aria.id, name: "Aria II" })).to include("name" => "Aria II")
    expect(aria.reload.name).to eq("Aria II")
  end

  it "adds and renames traits" do
    added = write("add_trait", { character_id: aria.id, name: " Archer " })
    expect(added).to eq("id" => aria.traits.find_by!(name: "archer").id, "character_id" => aria.id, "name" => "archer")
    expect(write("update_trait", { id: trait.id, name: "Paladin" })).to include("name" => "paladin")
    expect(aria.traits.pluck(:name)).to contain_exactly("archer", "paladin")
  end

  it "tags an image, once for each character" do
    bran = create(:character, universe: universe, name: "Bran")
    2.times { write("tag_image", { image_id: image.id, character_ids: [bran.id, aria.id, aria.id] }) }

    expect(write("tag_image", { image_id: image.id, character_ids: [aria.id] })["characters"].pluck("name"))
      .to eq(%w[Aria Bran])
    expect(image.appearances.count).to eq(2)
  end

  it "changes favorites of the token's user only" do
    create(:image_favorite, user: stranger, image: image)
    2.times { expect(write("favorite_image", { image_id: image.id })["favorited"]).to be(true) }
    expect(user.image_favorites.count).to eq(1)
    2.times { expect(write("unfavorite_image", { image_id: image.id })["favorited"]).to be(false) }

    expect(ImageFavorite.sole.user).to eq(stranger)
  end

  describe "refusals" do
    let(:calls) do
      { "create_character" => { universe_id: universe.id, name: "New" },
        "update_character" => { id: aria.id, name: "New" },
        "add_trait" => { character_id: aria.id, name: "new" },
        "update_trait" => { id: trait.id, name: "new" },
        "tag_image" => { image_id: image.id, character_ids: [aria.id] },
        "favorite_image" => { image_id: image.id },
        "unfavorite_image" => { image_id: image.id } }
    end
    let(:foreign_ids) do
      { universe_id: foreign_universe.id, character_id: foreign.id, image_id: foreign_image.id }
    end

    it "need the write scope" do
      before = everything
      calls.each { |tool, arguments| expect(tool_error(tool, arguments, token: reader)).to be_present }

      expect(everything).to eq(before)
      expect(tool_names(reader)).not_to include(*calls.keys)
      expect(tool_names(writer)).to include(*calls.keys)
    end

    it "treat others' records as absent" do
      user.update!(admin: true)
      before = everything
      calls.each do |tool, arguments|
        foreign_id = { "update_character" => foreign.id, "update_trait" => foreign_trait.id }[tool]
        name = arguments.keys.first
        errors = [foreign_id || foreign_ids.fetch(name), 999_999].map do |id|
          tool_error(tool, arguments.merge(name => id), token: writer)
        end

        expect(errors.uniq.sole).to end_with("not found"), tool
      end
      expect(everything).to eq(before)
    end

    it "do not tag characters of another universe, nor some of several" do
      other = create(:character, universe: create(:universe, owner: user))
      [foreign.id, other.id, 999_999].each do |id|
        expect(tool_error("tag_image", { image_id: image.id, character_ids: [aria.id, id] }, token: writer))
          .to eq("Character not found")
      end

      expect(Appearance.count).to eq(0)
    end

    it "give the models' messages" do
      create(:character, universe: universe, name: "Bran")
      create(:trait, character: aria, name: "archer")
      before = everything

      { "create_character" => { universe_id: universe.id, name: "ARIA" },
        "update_character" => { id: aria.id, name: "bran" },
        "add_trait" => { character_id: aria.id, name: "Knight " },
        "update_trait" => { id: trait.id, name: "archer" } }.each do |tool, arguments|
        expect(tool_error(tool, arguments, token: writer)).to include("Name has already been taken")
      end
      expect(tool_error("create_character", { universe_id: universe.id, name: " " }, token: writer))
        .to include("Name can't be blank")
      expect(everything).to eq(before)
    end

    it "accept no other fields" do
      before = everything
      [["update_character", { id: aria.id, name: "New", universe_id: foreign_universe.id }],
       ["create_character", { universe_id: universe.id, name: "New", id: 5 }],
       ["update_trait", { id: trait.id, name: "new", character_id: foreign.id }],
       ["favorite_image", { image_id: image.id, user_id: stranger.id }]].each do |tool, arguments|
        expect(tool_error(tool, arguments, token: writer)).to be_present
      end

      expect(everything).to eq(before)
    end
  end
end
