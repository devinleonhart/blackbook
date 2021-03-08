# frozen_string_literal: true

class CharactersController < ApplicationController
  before_action -> { require_universe_visible_to_user("character") },
    only: [:index, :create]

  def index
    begin
      @page = Integer(params[:page])
    rescue TypeError
      @page = 1
    rescue ArgumentError
      raise InvalidPaginationParameterError.new(
        "page",
        params[:page],
        "The value couldn't be parsed as an integer.",
      )
    end

    begin
      @page_size = Integer(params[:page_size])
    rescue TypeError
      @page_size = Rails.configuration.pagination_default_page_size
    rescue ArgumentError
      raise InvalidPaginationParameterError.new(
        "page_size",
        params[:page_size],
        "The value couldn't be parsed as an integer.",
      )
    end

    if @page < 1
      raise InvalidPaginationParameterError.new(
        "page",
        @page,
        "Pages start at 1.",
      )
    end

    if @page_size < 1
      raise InvalidPaginationParameterError.new(
        "page_size",
        @page_size,
        "Page size must be at least 1.",
      )
    end

    total_characters = Character.where(universe_id: params[:universe_id]).count
    @total_pages = (total_characters / @page_size.to_f).ceil

    @characters =
      Character
      .where(universe_id: params[:universe_id])
      .offset((@page - 1) * @page_size)
      .limit(@page_size)
      .order(created_at: :asc)
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
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

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

    raise MissingResource.new("character", params[:id]) if @character.nil?
  end

  def create
    properties =
      allowed_character_params.merge(universe_id: params[:universe_id])
    @character = Character.create!(properties)
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
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

    @character.update!(allowed_character_params)
    flash[:success] = "Character updated!"
    redirect_to character_url(@character)
  end

  def destroy
    @character = Character.find_by(id: params[:id])
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

    @character.destroy!
    flash[:success] = "Character deleted!"
    redirect_to universe_url(@character.universe)
  end

  private

  def allowed_character_params
    params.require(:character).permit(:name, :content, :page, images: [])
  end
end
