# frozen_string_literal: true

class TraitsController < ApplicationController
  before_action :set_character
  before_action :set_trait, only: [:show, :edit, :update, :destroy]

  def index
    @traits = @character.traits.order(:name)
  end

  def show
    @universe = @character.universe
    @characters_with_trait =
      @universe.characters
               .joins(:traits)
               .where(traits: { name: @trait.name })
               .distinct

    character_ids = @characters_with_trait.pluck(:id)
    @images =
      @universe.images
               .joins(:appearances)
               .where(appearances: { character_id: character_ids })
               .distinct
               .order("images.created_at DESC")
  end

  def edit; end

  def create
    @trait = @character.traits.build(trait_params)

    if @trait.save
      flash[:success] = "Trait added."
      redirect_to character_path(@character)
    else
      flash[:error] = @trait.errors.full_messages.join(", ")
      redirect_to character_traits_path(@character)
    end
  end

  def update
    if @trait.update(trait_params)
      flash[:success] = "Trait renamed."
      redirect_to character_traits_path(@character)
    else
      flash[:error] = @trait.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @trait.destroy!
    flash[:success] = "Trait removed."
    redirect_back_or_to(character_path(@character))
  end

  private

  def set_character
    if params[:character_id]
      @character = Character.find_by(id: params[:character_id])
      return unless model_found?(@character, "Character", params[:character_id], universes_url)
    else
      @trait = Trait.find_by(id: params[:id])
      return unless model_found?(@trait, "Trait", params[:id], universes_url)

      @character = @trait.character
    end

    universe_visible_to_user?(@character.universe)
  end

  def set_trait
    @trait = @character.traits.find(params.expect(:id)) if @trait.nil?
  end

  def trait_params
    params.expect(trait: [:name])
  end
end
