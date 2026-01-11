# frozen_string_literal: true

class CharacterTagsController < ApplicationController
  before_action :set_character
  before_action :set_character_tag, only: [:show, :edit, :update, :destroy]

  def index
    @character_tags = @character.character_tags.order(:name)
  end

  def show
    @universe = @character.universe
    @characters_with_tag =
      @universe.characters
               .joins(:character_tags)
               .where(character_tags: { name: @character_tag.name })
               .distinct

    character_ids = @characters_with_tag.pluck(:id)
    @images =
      @universe.images
               .joins(:image_tags)
               .where(image_tags: { character_id: character_ids })
               .distinct
               .order("images.created_at DESC")
  end

  def new
    @character_tag = @character.character_tags.build
  end

  def edit; end

  def create
    @character_tag = @character.character_tags.build(character_tag_params)

    if @character_tag.save
      flash[:success] = "Character tag created successfully!"
      redirect_to character_path(@character)
    else
      flash[:error] = @character_tag.errors.full_messages.join(", ")
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @character_tag.update(character_tag_params)
      flash[:success] = "Character tag updated successfully!"
      redirect_to character_character_tags_path(@character)
    else
      flash[:error] = @character_tag.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @character_tag.destroy!
    flash[:success] = "Character tag deleted successfully!"
    redirect_to character_character_tags_path(@character)
  end

  private

  def set_character
    if params[:character_id]
      @character = Character.find(params[:character_id])
    else
      @character_tag = CharacterTag.find(params[:id])
      @character = @character_tag.character
    end
    universe_visible_to_user?(@character.universe)
    nil
  end

  def set_character_tag
    @character_tag = @character.character_tags.find(params[:id]) if @character_tag.nil?
  end

  def character_tag_params
    params.expect(character_tag: [:name])
  end
end
