# frozen_string_literal: true

class CharactersController < ApplicationController
  def show
    @character =
      Character
      .includes(
        image_tags: [:image]
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    @universe = @character.universe
    @untagged_images_count = Image.where(universe_id: @universe.id).untagged.count
    @images =
      Image
      .joins(:image_tags)
      .where(image_tags: { character: @character })
      .joins(
        Image.sanitize_sql_array(
          ["LEFT JOIN image_favorites ON image_favorites.image_id = images.id AND image_favorites.user_id = ?",
           current_user.id]
        )
      )
      .order(Arel.sql("image_favorites.id IS NOT NULL DESC"), created_at: :desc)
      .paginate(page: params[:page], per_page: 20)

    # Tags used anywhere in this universe, and the subset this character
    # doesn't have yet. The set difference is done in Ruby from two loaded
    # lists rather than one exists? query per universe tag.
    @universe_tag_names = @universe.characters.joins(:character_tags).distinct.pluck("character_tags.name").sort
    @available_tag_names = @universe_tag_names - @character.character_tags.pluck(:name)
  end

  def new
    universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(universe, "Universe", params[:universe_id], universes_url)
    return unless universe_visible_to_user?(universe)

    @new_character = Character.new(universe_id: universe.id)
  end

  def edit
    @character =
      Character
      .includes(
        image_tags: [:image]
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    @universe = @character.universe
  end

  def create
    universe = Universe.find_by(id: params[:universe_id])
    return unless model_found?(universe, "Universe", params[:universe_id], universes_url)
    return unless universe_visible_to_user?(universe)

    @character = Character.new(allowed_character_params.merge(universe_id: universe.id))

    if @character.save
      flash[:success] = "Character created!"
      redirect_to character_url(@character)
    else
      flash[:error] = @character.errors.full_messages.join("\n")
      redirect_to new_universe_character_url(universe)
    end
  end

  def update
    @character =
      Character
      .includes(
        image_tags: [:image]
      )
      .find_by(id: params[:id])

    return unless model_found?(@character, "Character", params[:id], universes_url)
    return unless universe_visible_to_user?(@character.universe)

    if @character.update(allowed_character_params)
      flash[:success] = "Character updated!"
      redirect_to character_url(@character)
    else
      flash[:error] = @character.errors.full_messages.join("\n")
      redirect_to edit_character_url(params[:id])
    end
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
    params.expect(character: [:name, :page, { images: [] }])
  end
end
