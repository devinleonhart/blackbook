# frozen_string_literal: true

class MutualRelationshipsController < ApplicationController
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

    this_character = Character.find_by(id: this_character_id)
    target_character = Character.find_by(id: target_character_id)
    forward_name = allowed_mutual_relationship_create_params[:forward_name]
    reverse_name = allowed_mutual_relationship_create_params[:reverse_name]

    if this_character.nil? || target_character.nil?
      error_and_redirect("One of the two characters you are trying to relate does not exist.", universes_url)
      return
    end

    if forward_name.blank? || reverse_name.blank?
      error_and_redirect("Both directions of the relationship must be specified.", universes_url)
      return
    end

    unless universe_visible_to_user?(this_character.universe) && universe_visible_to_user?(target_character.universe)
      return
    end

    ActiveRecord::Base.transaction do
      @mutual_relationship = MutualRelationship.create!
      Relationship.create!(
        originating_character_id: this_character_id,
        target_character_id: target_character_id,
        name: forward_name,
        mutual_relationship: @mutual_relationship,
      )
      Relationship.create!(
        originating_character_id: target_character_id,
        target_character_id: this_character_id,
        name: reverse_name,
        mutual_relationship: @mutual_relationship,
      )
      @mutual_relationship.reload
    end

    flash[:success] = "Mutual Relationship created!"
    redirect_to edit_character_url(params[:character_id])
  end

  def destroy
    @mutual_relationship = MutualRelationship.find_by(id: params[:id])
    return unless model_found?(@mutual_relationship, "Mutual Relationship", params[:id], universes_url)
    return unless universe_visible_to_user?(@mutual_relationship.universe)

    @mutual_relationship.destroy!
    flash[:success] = "Mutual Relationship deleted!"
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
