# frozen_string_literal: true

class TraitsController < ApplicationController
  before_action :set_character
  before_action :set_trait, only: [:show, :edit, :update, :destroy]

  def index
    @traits = @character.traits.order(:name)
  end

  def show
    @universe = @character.universe
    @characters_with_tag =
      @universe.characters
               .joins(:traits)
               .where(traits: { name: @trait.name })
               .distinct

    character_ids = @characters_with_tag.pluck(:id)
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
      flash[:success] = "Character tag created successfully!"
      redirect_to character_path(@character)
    else
      flash[:error] = @trait.errors.full_messages.join(", ")
      redirect_to character_traits_path(@character)
    end
  end

  def update
    if @trait.update(trait_params)
      flash[:success] = "Character tag updated successfully!"
      redirect_to character_traits_path(@character)
    else
      flash[:error] = @trait.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @trait.destroy!
    flash[:success] = "Character tag deleted successfully!"
    redirect_to character_traits_path(@character)
  end

  private

  def set_character
    if params[:character_id]
      @character = Character.find(params.expect(:character_id))
    else
      @trait = Trait.find(params.expect(:id))
      @character = @trait.character
    end
    universe_visible_to_user?(@character.universe)
    nil
  end

  def set_trait
    @trait = @character.traits.find(params.expect(:id)) if @trait.nil?
  end

  def trait_params
    params.expect(trait: [:name])
  end
end
