# frozen_string_literal: true

class API::V1::MutualRelationshipsController < API::V1::ApplicationController
  before_action -> { require_universe_visible_to_user("relationships") },
    only: [:index, :create]

  def index
    @mutual_relationships =
      Relationship
      .includes(:target_character)
      .where(originating_character_id: params[:character_id])
      .all
  end

  def show
    @mutual_relationship =
      MutualRelationship
      .includes(relationships: [:originating_character, :target_character])
      .find_by(id: params[:id])

    if @mutual_relationship.nil?
      raise MissingResource.new("MutualRelationship", params[:id])
    end

    require_universe_visible_to_user(
      "relationships",
      @mutual_relationship.universe.id,
    )
  end

  def create
    this_character_id = params[:character_id]
    target_character_id =
      allowed_mutual_relationship_create_params[:target_character_id]

    ActiveRecord::Base.transaction do
      @mutual_relationship = MutualRelationship.create!
      Relationship.create!(
        originating_character_id: this_character_id,
        target_character_id: target_character_id,
        name: allowed_mutual_relationship_create_params[:forward_name],
        mutual_relationship: @mutual_relationship,
      )
      Relationship.create!(
        originating_character_id: target_character_id,
        target_character_id: this_character_id,
        name: allowed_mutual_relationship_create_params[:reverse_name],
        mutual_relationship: @mutual_relationship,
      )
      @mutual_relationship.reload
    end
  end

  def update
    @mutual_relationship =
      MutualRelationship
      .includes(relationships: [:originating_character, :target_character])
      .find_by(id: params[:id])

    if @mutual_relationship.nil?
      raise MissingResource.new("MutualRelationship", params[:id])
    end

    require_universe_visible_to_user(
      "relationships",
      @mutual_relationship.universe.id,
    )

    originating_character_id =
      allowed_mutual_relationship_update_params[:originating_character_id]
      .to_i

    character_ids_in_relationship = @mutual_relationship.characters.map(&:id)
    unless character_ids_in_relationship.include?(originating_character_id)
      raise InvalidCharacterIdForRelationship.new(
        @mutual_relationship.id,
        originating_character_id,
      )
    end

    ActiveRecord::Base.transaction do
      @mutual_relationship.relationships.each do |relationship|
        forward_direction =
          relationship.originating_character.id == originating_character_id
        new_name = if forward_direction
          allowed_mutual_relationship_update_params[:forward_name]
        else
          allowed_mutual_relationship_update_params[:reverse_name]
        end

        unless new_name.nil?
          relationship.name = new_name
          relationship.save!
        end
      end
    end

    @mutual_relationship
  end

  def destroy
    @mutual_relationship = MutualRelationship.find_by(id: params[:id])
    if @mutual_relationship.nil?
      raise MissingResource.new("MutualRelationship", params[:id])
    end

    require_universe_visible_to_user(
      "relationships",
      @mutual_relationship.universe.id,
    )

    @mutual_relationship.destroy!
    head :no_content
  end

  private

  def allowed_mutual_relationship_create_params
    params.require(:mutual_relationship).permit(
      :forward_name,
      :reverse_name,
      :target_character_id,
    )
  end

  def allowed_mutual_relationship_update_params
    params.require(:mutual_relationship).require(:originating_character_id)
    params.require(:mutual_relationship).permit(
      :originating_character_id,
      :forward_name,
      :reverse_name,
    )
  end
end
