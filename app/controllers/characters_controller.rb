# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action :set_universe, only: [:new, :create]
  before_action :set_character, only: [:show, :edit, :update, :destroy]

  def show
    @universe = @character.universe
    @images =
      Image
      .joins(:appearances)
      .where(appearances: { character: @character })
      .joins(
        Image.sanitize_sql_array(
          ["LEFT JOIN image_favorites ON image_favorites.image_id = images.id AND image_favorites.user_id = ?",
           current_user.id]
        )
      )
      .order(Arel.sql("image_favorites.id IS NOT NULL DESC"), created_at: :desc)
      .paginate(page: params[:page], per_page: 20)

    @universe_trait_names = @universe.characters.joins(:traits).distinct.pluck("traits.name").sort
    @available_trait_names = @universe_trait_names - @character.traits.pluck(:name)
  end

  def new
    @new_character = Character.new(universe_id: @universe.id)
  end

  def edit
    @universe = @character.universe
  end

  def create
    @character = Character.new(allowed_character_params.merge(universe_id: @universe.id))

    if @character.save
      flash[:success] = "Character created!"
      redirect_to character_url(@character)
    else
      flash[:error] = @character.errors.full_messages.join("\n")
      redirect_to new_universe_character_url(@universe)
    end
  end

  def update
    if @character.update(allowed_character_params)
      flash[:success] = "Character updated!"
      redirect_to character_url(@character)
    else
      flash[:error] = @character.errors.full_messages.join("\n")
      redirect_to edit_character_url(@character)
    end
  end

  def destroy
    @character.destroy!
    flash[:success] = "Character deleted!"
    redirect_to universe_url(@character.universe)
  end

  private

  def set_universe
    @universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(@universe, "Universe", params[:universe_id], universes_url)

    universe_visible_to_user?(@universe)
  end

  def set_character
    @character = Character.includes(appearances: [:image]).find_by(id: params[:id])
    return unless model_found?(@character, "Character", params[:id], universes_url)

    universe_visible_to_user?(@character.universe)
  end

  def allowed_character_params
    params.expect(character: [:name, :page, { images: [] }])
  end
end
