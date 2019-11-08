# frozen_string_literal: true

class API::V1::CharactersController < API::V1::ApplicationController
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
  end

  def create
    properties =
      allowed_character_params.merge(universe_id: params[:universe_id])
    @character = Character.create!(properties)
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
  end

  def destroy
    @character = Character.find_by(id: params[:id])
    raise MissingResource.new("character", params[:id]) if @character.nil?

    require_universe_visible_to_user("character", @character.universe.id)

    @character.destroy!
    head :no_content
  end

  private

  def allowed_character_params
    params.require(:character).permit(:name, :description, images: [])
  end
end
