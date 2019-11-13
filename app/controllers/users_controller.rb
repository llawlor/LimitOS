class UsersController < ApplicationController

  def account
    # get the user
    @user = current_user
    # redirect if no user
    redirect_to root_path and return if @user.blank?
  end

end
