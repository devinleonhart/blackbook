# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
  end

  private

  def allowed_universe_params
    params.require(:user).permit()
  end
end
