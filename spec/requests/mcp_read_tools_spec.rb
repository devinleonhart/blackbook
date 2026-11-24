# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP read tools", type: :request do
  include_context "with MCP"

  let(:aria) { create(:character, universe: universe, name: "Aria") }
  let(:bran) { create(:character, universe: universe, name: "Bran") }
  let(:image) { create(:image, universe: universe) }

  def read(name, arguments = {})
    tool_data(name, arguments, token: reader)
  end

  def ids(result)
    result["items"].pluck("id")
  end

  def image_data(record, characters: [], favorited: false)
    blob = record.image_file.blob
    { "id" => record.id, "universe_id" => record.universe_id,
      "characters" => characters.map { |character| { "id" => character.id, "name" => character.name } },
      "favorited" => favorited, "content_type" => "image/jpeg", "byte_size" => blob.byte_size,
      "created_at" => record.created_at.utc.iso8601,
      "url" => "https://blackbook.devleo.me/images/#{record.id}/#{blob.filename}",
      "page" => "https://blackbook.devleo.me/universes/#{record.universe_id}/images/#{record.id}/edit" }
  end

  def edit_page(record)
    edit_universe_image_path(record.universe, record)
  end

  it "describes a universe" do
    create(:trait, character: aria, name: "knight")
    create(:trait, character: bran, name: "knight")
    create(:trait, character: bran, name: "archer")
    create(:appearance, character: aria, image: image)
    create(:image, universe: universe)

    expect(read("get_universe", { id: universe.id })).to include(
      "id" => universe.id, "name" => universe.name, "role" => "owner", "characters" => 2, "images" => 2,
      "untagged_images" => 1,
      "traits" => [{ "name" => "knight", "characters" => 2 }, { "name" => "archer", "characters" => 1 }]
    )
  end

  it "lists and filters characters" do
    create(:trait, character: aria, name: "knight")
    create(:appearance, character: aria, image: image)
    bran
    create(:character, name: "Elsewhere", universe: create(:universe, owner: user))

    expect(read("list_characters", { universe_id: universe.id })).to eq(
      "items" => [
        { "id" => aria.id, "universe_id" => universe.id, "name" => "Aria", "traits" => ["knight"], "images" => 1 },
        { "id" => bran.id, "universe_id" => universe.id, "name" => "Bran", "traits" => [], "images" => 0 }
      ],
      "total" => 2, "page" => 1, "next_page" => nil
    )
    expect(ids(read("list_characters", { universe_id: universe.id, name: "RA" }))).to eq([bran.id])
    expect(ids(read("list_characters", { universe_id: universe.id, name: "%" }))).to eq([])
    expect(ids(read("list_characters", { universe_id: universe.id, trait: " Knight " }))).to eq([aria.id])
    expect(read("list_characters", {})["total"]).to eq(3)
  end

  it "describes a character" do
    trait = create(:trait, character: aria, name: "knight")
    create(:appearance, character: aria, image: image)

    expect(read("get_character", { id: aria.id })).to eq(
      "id" => aria.id, "universe_id" => universe.id, "name" => "Aria",
      "traits" => [{ "id" => trait.id, "name" => "knight" }], "images" => 1
    )
  end

  it "lists traits with counts" do
    [aria, bran].each { |character| create(:trait, character: character, name: "knight") }
    create(:trait, character: aria, name: "archer")
    create(:trait, name: "foreign")

    expect(read("list_traits", { universe_id: universe.id })).to eq(
      [{ "name" => "knight", "characters" => 2 }, { "name" => "archer", "characters" => 1 }]
    )
  end

  it "lists and filters images, newest first" do
    create(:appearance, character: aria, image: image)
    second = create(:image, universe: universe, created_at: 1.day.from_now)
    create(:image_favorite, user: user, image: second)
    create(:image_favorite, user: stranger, image: image)
    all = { universe_id: universe.id }

    expect(read("list_images", all)).to eq(
      "items" => [image_data(second, favorited: true), image_data(image.reload, characters: [aria])],
      "total" => 2, "page" => 1, "next_page" => nil
    )
    expect(ids(read("list_images", all.merge(character_id: aria.id)))).to eq([image.id])
    expect(ids(read("list_images", all.merge(untagged: true)))).to eq([second.id])
    expect(ids(read("list_images", all.merge(favorites: true)))).to eq([second.id])
    expect(ids(read("list_images", all.merge(untagged: false, favorites: false)))).to eq([second.id, image.id])
    expect(ids(read("list_images", { character_id: aria.id }))).to eq([image.id])
  end

  it "describes an image by its address, never by its data" do
    create(:appearance, character: aria, image: image)
    result = call_tool("get_image", { id: image.id }, token: reader)["result"]

    expect(JSON.parse(result["content"].sole["text"])).to eq(image_data(image.reload, characters: [aria]))
    expect(result["content"].sole["type"]).to eq("text")
    expect(response.body).not_to match(%r{[A-Za-z0-9+/]{200}})
    expect(image_data(image)["page"]).to end_with(edit_page(image))
    expect(image_data(image)["url"]).to end_with(view_image_path(image, image.image_file.filename))
  end

  it "does not read image files" do
    image
    allow(ActiveStorage::Blob.service).to receive(:download).and_raise("read a file")
    allow(ActiveStorage::Blob.service).to receive(:download_chunk).and_raise("read a file")

    expect(ids(read("list_images", {}))).to eq([image.id])
  end

  it "lists the user's favorites in accessible universes" do
    lost = create(:image, universe: foreign_universe)
    [image, lost].each { |favorite| create(:image_favorite, user: user, image: favorite) }
    create(:image_favorite, user: stranger, image: create(:image, universe: universe))

    expect(ids(read("list_favorites"))).to eq([image.id])
  end

  it "serves collaborators" do
    create(:collaboration, user: user, universe: foreign_universe)
    character = create(:character, universe: foreign_universe)
    shared = create(:image, universe: foreign_universe)

    expect(read("get_universe", { id: foreign_universe.id })["role"]).to eq("collaborator")
    expect(read("get_character", { id: character.id })["id"]).to eq(character.id)
    expect(read("get_image", { id: shared.id })["id"]).to eq(shared.id)
    expect(ids(read("list_images", {}))).to eq([shared.id])
  end

  it "pages" do
    expect(read("list_characters", {})).to eq("items" => [], "total" => 0, "page" => 1, "next_page" => nil)
    create(:character, universe: universe)
    expect(read("list_characters", {})).to include("total" => 1, "next_page" => nil)
    create_list(:character, 49, universe: universe)
    expect(read("list_characters", {})["next_page"]).to be_nil
    create(:character, universe: universe)
    expect(read("list_characters", {})).to include("total" => 51, "next_page" => 2)
    expect(read("list_characters", { page: 2 })).to include("page" => 2, "next_page" => nil)
    expect(read("list_characters", { page: 2 })["items"].size).to eq(1)
    expect(read("list_characters", { page: 3 })["items"]).to eq([])
    create_list(:character, 50, universe: universe)
    pages = [1, 2].map { |page| ids(read("list_characters", { per_page: 100, page: page })) }
    expect(pages.map(&:size)).to eq([100, 1])
    expect(pages.flatten.uniq.size).to eq(101)
    [{ page: 0 }, { page: -1 }, { per_page: 101 }, { per_page: 0 }, { page: "2" }].each do |arguments|
      expect(tool_error("list_characters", arguments, token: reader)).to be_present
    end
  end

  it "gives one error for absent and inaccessible records" do
    character = create(:character, universe: foreign_universe)
    hidden = create(:image, universe: foreign_universe)
    user.update!(admin: true)

    { "get_universe" => [:id, foreign_universe], "list_traits" => [:universe_id, foreign_universe],
      "list_characters" => [:universe_id, foreign_universe], "list_images" => [:universe_id, foreign_universe],
      "get_character" => [:id, character], "get_image" => [:id, hidden] }.each do |tool, (name, record)|
      errors = [record.id, 999_999, 9_007_199_254_740_991].map { |id| tool_error(tool, { name => id }, token: reader) }

      expect(errors.uniq).to eq(["#{record.class.name} not found"])
    end
    expect(tool_error("list_images", { character_id: character.id }, token: reader)).to eq("Character not found")
  end

  it "shows nothing of inaccessible universes in unfiltered lists" do
    character = create(:character, universe: foreign_universe)
    create(:appearance, character: character, image: create(:image, universe: foreign_universe))

    %w[list_characters list_images list_favorites].each { |tool| expect(read(tool)["total"]).to eq(0) }
  end

  it "runs as many queries for many records as for few" do
    add = lambda do |count|
      Array.new(count) do
        character = create(:character, universe: universe)
        create(:trait, character: character)
        create(:appearance, character: character, image: create(:image, universe: universe))
      end
    end
    count = ->(tool) { queries { read(tool) }.size }
    add.call(2)
    # The first calls also load the schema.
    %w[list_characters list_images list_universes].each { |tool| read(tool) }
    few = %w[list_characters list_images list_universes].map(&count)
    add.call(20)

    expect(%w[list_characters list_images list_universes].map(&count)).to eq(few)
  end

  it "needs the read scope" do
    weak = issue_token(user)
    TailnetMcp::Token.authenticate(weak).update_column(:scopes, []) # rubocop:disable Rails/SkipsModelValidations

    expect(tool_names(weak)).to eq([])
    expect(tool_error("list_universes", token: weak)).to be_present
  end

  it "offers eight read tools" do
    expect(tool_names(reader)).to match_array(
      %w[list_universes get_universe list_characters get_character list_traits list_images get_image list_favorites]
    )
  end
end
