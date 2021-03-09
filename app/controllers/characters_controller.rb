# frozen_string_literal: true

class CharactersController < ApplicationController
  def index
    @characters = Character.where(universe_id: params[:universe_id]).order(created_at: :asc)
  end

  def new
    @new_character = Character.new(universe_id: params[:universe_id])
  end

  def show
    @character =
      Character
      .includes(
        character_items: [:item],
        character_traits: [:trait],
        image_tags: [:image],
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    @images = Image.joins(:image_tags).where(image_tags: { character: @character }).order(created_at: :desc).paginate(
page: params[:page], per_page: 18
)
  end

  def edit
    @character =
      Character
      .includes(
        character_items: [:item],
        character_traits: [:trait],
        image_tags: [:image],
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)
  end

  def create
    properties = allowed_character_params.merge(universe_id: params[:universe_id])
    @character = Character.create!(properties)
    flash[:success] = "Character created!"
    redirect_to character_url(@character)
  end

  def update
    @character =
      Character
      .includes(
        character_items: [:item],
        character_traits: [:trait],
        image_tags: [:image],
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    @character.update!(allowed_character_params)
    flash[:success] = "Character updated!"
    redirect_to character_url(@character)
  end

  def destroy
    @character = Character.find_by(id: params[:id])
    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    @character.destroy!
    flash[:success] = "Character deleted!"
    redirect_to universe_url(@character.universe)
  end

  private

  def allowed_character_params
    params.require(:character).permit(:name, :content, :page, images: [])
  end
end
