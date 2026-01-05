# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin!

  def index
    @users = User.all
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
