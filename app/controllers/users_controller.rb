# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin!

  def index
    @users = User.order(:email)
    # Grouped queries keyed by owner id, so the view avoids per-row COUNTs.
    @universe_counts = Universe.group(:owner_id).count
    @image_counts = Image.joins(:universe).group("universes.owner_id").count
  end

  def toggle_admin
    user = User.find_by(id: params[:id])
    return unless model_found?(user, "User", params[:id], users_url)

    if user == current_user
      flash[:error] = "You can't change your own admin status."
    else
      user.update!(admin: !user.admin)
      flash[:success] = "#{user.display_name} is #{user.admin ? 'now an admin' : 'no longer an admin'}."
    end

    redirect_to users_url
  end

  def destroy
    user = User.find_by(id: params[:id])
    return unless model_found?(user, "User", params[:id], users_url)

    if user.destroy
      flash[:success] = "User deleted."
    else
      flash[:error] = user.errors.full_messages.join("\n")
    end

    redirect_to users_url
  end
end
