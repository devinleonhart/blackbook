# frozen_string_literal: true

class MutualRelationshipsController < ApplicationController
  before_action lambda {
    character = Character.find_by(id: params[:character_id])
    raise MissingResource.new("character", params[:character_id]) if character.nil?

    require_universe_visible_to_user("relationships", character&.universe_id)
  }, only: [:index, :create]

  def index
    @mutual_relationships =
      Relationship
      .includes(:target_character)
      .where(originating_character_id: params[:character_id])
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
    redirect_to edit_character_url(params[:character_id])
  end

  def destroy
    @mutual_relationship = MutualRelationship.find_by(id: params[:id])
    raise MissingResource.new("MutualRelationship", params[:id]) if @mutual_relationship.nil?

    require_universe_visible_to_user(
      "relationships",
      @mutual_relationship.universe.id,
    )

    @mutual_relationship.destroy!
    redirect_to edit_character_url(allowed_mutual_relationship_delete_params[:redirecting_character_id])
  end

  private

  def allowed_mutual_relationship_create_params
    params.require(:mutual_relationship).permit(
      :forward_name,
      :reverse_name,
      :target_character_id,
    )
  end

  def allowed_mutual_relationship_delete_params
    params.require(:mutual_relationship).require(:redirecting_character_id)
    params.require(:mutual_relationship).permit(
      :redirecting_character_id,
    )
  end
end
