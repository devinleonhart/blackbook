# frozen_string_literal: true

class UniversesController < ApplicationController
  before_action :set_universe, only: [:show, :edit, :update]
  # Creating universes is an admin action — individual users don't self-serve
  # new universes; an admin creates one and assigns it an owner.
  before_action :require_admin!, only: [:new, :create]

  def index
    @universes = Universe.accessible_to(current_user)

    # Counts for every universe in two grouped queries, so the view doesn't
    # run a per-row COUNT (N+1). Missing keys default to 0.
    universe_ids = @universes.map(&:id)
    @character_counts = Character.where(universe_id: universe_ids).group(:universe_id).count
    @image_counts = Image.where(universe_id: universe_ids).group(:universe_id).count
  end

  def show
    @images_filter = params[:filter].presence

    base_images =
      Image
      .with_attached_image_file
      .where(universe_id: @universe.id)
      .order(created_at: :desc)

    @untagged_images_count = base_images.untagged.count

    @images =
      case @images_filter
      when "untagged"
        base_images.untagged
      else
        base_images
      end
      .paginate(page: params[:page], per_page: 20)

    # Load character tags for the tag browser
    @character_tags = CharacterTag.joins(:character)
                                  .where(characters: { universe_id: @universe.id })
                                  .group(:name)
                                  .count
                                  .sort_by { |name, count| [-count, name] }

    # Get the first character_tag ID for each tag name for linking
    @tag_name_to_id = CharacterTag.joins(:character)
                                  .where(characters: { universe_id: @universe.id })
                                  .group(:name)
                                  .minimum(:id)
  end

  def new
    @new_universe = Universe.new
    @users = User.order(:display_name)
  end

  def edit
    @users = User.all
    @collaborations = @universe.collaborations.includes(:user)
  end

  def create
    @universe = Universe.new(allowed_universe_params)
    if @universe.save
      flash[:success] = "Universe \"#{@universe.name}\" created for #{@universe.owner.display_name}."
      redirect_to users_url
    else
      flash[:error] = @universe.errors.full_messages.join("\n")
      redirect_to new_universe_url
    end
  end

  def update
    if @universe.update(allowed_universe_params)
      flash[:success] = "Universe updated!"
      redirect_to universes_url
    else
      flash[:error] = @universe.errors.full_messages.join("\n")
      redirect_to edit_universe_url(@universe)
    end
  end

  private

  def set_universe
    @universe = Universe.find_by(id: params[:id])
    return unless model_found?(@universe, "Universe", params[:id], universes_url)

    universe_visible_to_user?(@universe)
  end

  def allowed_universe_params
    params.expect(
      universe: [:name,
                 :owner_id,
                 :page,
                 { collaborator_ids: [] }]
    )
  end
end
