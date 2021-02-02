# frozen_string_literal: true

class API::V1::UsersController < API::V1::ApplicationController
  def show
    @user = User.find_by(id: params[:id])
    raise MissingResource.new("user", params[:id]) if @user.nil?
  end

  def update
    @user = User.find_by(id: params[:id])
    raise MissingResource.new("user", params[:id]) if @user.nil?

    @user.update!(allowed_user_params)
  end

  private

  def allowed_user_params
    params.require(:user).permit(:avatar)
  end
end
