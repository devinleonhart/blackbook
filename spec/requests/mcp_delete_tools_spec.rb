# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP delete tools", type: :request do
  include_context "with MCP"

  let!(:aria) { create(:character, universe: universe) }
  let!(:trait) { create(:trait, character: aria) }
  let!(:image) { create(:image, universe: universe) }
  let!(:bran) { create(:character, universe: universe) }
  let!(:foreign) { create(:character, universe: foreign_universe) }
  let!(:foreign_trait) { create(:trait, character: foreign) }
  let!(:foreign_image) { create(:image, universe: foreign_universe) }

  let(:calls) do
    { "delete_character" => { id: aria.id }, "delete_trait" => { id: trait.id },
      "untag_image" => { image_id: image.id, character_id: aria.id } }
  end

  before { create(:appearance, character: aria, image: image) }

  def counts
    [Universe, User, Character, Trait, Appearance, Image, ActiveStorage::Blob, ActiveStorage::Attachment].map(&:count)
  end

  it "deletes a trait" do
    expect(tool_data("delete_trait", { id: trait.id }, token: token)).to eq("deleted" => true, "id" => trait.id)
    expect(Trait.all).to eq([foreign_trait])
  end

  it "removes a character from an image" do
    create(:appearance, character: bran, image: image)
    result = tool_data("untag_image", { image_id: image.id, character_id: aria.id }, token: token)

    expect(result["characters"].pluck("id")).to eq([bran.id])
    expect(Appearance.sole.character).to eq(bran)
    expect(tool_error("untag_image", { image_id: image.id, character_id: aria.id }, token: token))
      .to eq("Character not found")
  end

  it "deletes a character and keeps its images" do
    expect(tool_data("delete_character", { id: aria.id }, token: token)).to eq("deleted" => true, "id" => aria.id)

    expect(Character.all).to contain_exactly(bran, foreign)
    expect(Trait.all).to eq([foreign_trait])
    expect(Image.count).to eq(2)
    expect(ActiveStorage::Attachment.count).to eq(2)
    expect(image.reload.image_file).to be_attached
  end

  it "needs the delete scope" do
    before = counts
    [reader, writer].each do |weak|
      calls.each { |tool, arguments| expect(tool_error(tool, arguments, token: weak)).to be_present }
      expect(tool_names(weak)).not_to include(*calls.keys)
    end

    expect(counts).to eq(before)
  end

  it "treats others' records as absent" do
    user.update!(admin: true)
    before = counts
    foreign_calls = [["delete_character", :id, foreign.id, {}], ["delete_trait", :id, foreign_trait.id, {}],
                     ["untag_image", :image_id, foreign_image.id, { character_id: aria.id }],
                     ["untag_image", :character_id, foreign.id, { image_id: image.id }]]

    foreign_calls.each do |tool, name, id, rest|
      errors = [id, 999_999].map { |value| tool_error(tool, rest.merge(name => value), token: token) }
      expect(errors.uniq.sole).to end_with("not found")
    end
    expect(counts).to eq(before)
  end

  it "marks its tools as destructive, and only them" do
    tools = mcp_request("tools/list", token: token).dig("result", "tools")

    expect(tools.select { |tool| tool.dig("annotations", "destructiveHint") }.pluck("name")).to match_array(calls.keys)
    expect(tools.select { |tool| tool.dig("annotations", "readOnlyHint") }.size).to eq(8)
  end

  it "offers these tools and no others" do
    expect(tool_names(token)).to match_array(
      %w[list_universes get_universe list_characters get_character list_traits list_images get_image list_favorites
         create_character update_character add_trait update_trait tag_image favorite_image unfavorite_image
         delete_character delete_trait untag_image]
    )
    described = mcp_request("tools/list", token: token).dig("result", "tools")
    fields = described.flat_map { |tool| tool.dig("inputSchema", "properties").to_h.keys }.uniq
    expect(fields).to match_array(%w[id universe_id character_id image_id character_ids name trait untagged favorites
                                     page per_page])
    expect(described.pluck("name").grep(/owner|collaborator|user|delete_image|universe/))
      .to match_array(%w[list_universes get_universe])
  end
end
